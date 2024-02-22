// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// The wallet owners can
// 1.submit a transaction
// 2.approve and revoke approval of pending transactions
// 3.anyone can execute a transaction after enough owners has approved it.
contract MultiSigWallet {
    address[] public owners;
    uint public min_confirm;
    struct Transaction {
        address to;
        uint value;
        bytes data;
    }
    Transaction[] transactions;
    mapping(uint => uint) num_confirmations; //tx id =>confirmation number
    mapping(uint => mapping(address=>bool)) confirmed;
    mapping(uint => bool) executed;
    mapping(address => bool) isOwner;

    event SubmitTransaction(address owner, uint index_tx);
    event ApproveTransaction(address owner, uint index_tx);
    event RevokeApproval(address owner, uint index_tx);
    event ExecuteTransaction(address executor, uint index_tx);

    modifier onlyOwenr() {
        require(isOwner[msg.sender] == true, "not Owner!");
        _;
    }
    modifier txExist(uint index_tx){
        require(index_tx < transactions.length, "transaction not exist!");
        _;
    }

    modifier notConfirmed(uint index_tx) {
        require(num_confirmations[index_tx]<min_confirm, "confirmed yet");
        _;
    }

    modifier notExecute(uint index_tx) {
        require(executed[index_tx] == false, "executed yet!");
        _;
    }

    constructor(address[] memory _owners, uint _min_confirm) {
        require(_owners.length > 0, "Empty owners");
        require(
            _min_confirm < _owners.length,
            "Minimal confirmation should less than owner numbers!"
        );
        min_confirm = _min_confirm;
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "empty address!");
            require(!isOwner[_owners[i]], "owner not unique");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwenr {
        require(_to != address(0));
        uint index = transactions.length;
        Transaction memory transaction = Transaction({
            to: _to,
            value: _value,
            data: _data
        });
        transactions.push(transaction);
        num_confirmations[index] = 0;
        executed[index] = false;
        emit SubmitTransaction(msg.sender, transactions.length);
    }

    function confirmTransaction(
        uint index_tx
    ) public onlyOwenr txExist(index_tx) notConfirmed(index_tx) notExecute(index_tx) {
        require(confirmed[index_tx][msg.sender]==false,"You have approved this transcation!");
        num_confirmations[index_tx] += 1;
        confirmed[index_tx][msg.sender] = true;
        emit ApproveTransaction(msg.sender, index_tx);
        if (num_confirmations[index_tx] >= min_confirm) {
            //The last one person to confirm tx will pay gas fee
            executeTransaction(index_tx); //自动执行交易
        }
    }

    function revokeApproval(
        uint index_tx
    ) public onlyOwenr txExist(index_tx) notConfirmed(index_tx) notExecute(index_tx) {
        require(confirmed[index_tx][msg.sender]==true,"You have not approved this transcation!");
        confirmed[index_tx][msg.sender]==false;
        num_confirmations[index_tx] -= 1;
        emit RevokeApproval(msg.sender, index_tx);
    }

    function executeTransaction(uint index_tx) public notExecute(index_tx) {
        require(num_confirmations[index_tx]>= min_confirm, "not confirmed!");
        address to = transactions[index_tx].to;
        uint amount = transactions[index_tx].value;
        bytes memory data = transactions[index_tx].data;
        executed[index_tx] = true;
        (bool success, ) = to.call{value: amount}(data);
        require(success, "execute failed!");
        emit ExecuteTransaction(msg.sender, index_tx);
    }

    function addOwners(address[] memory new_owners)public{
        require(msg.sender == address(this),"only owners can execute this function");
        for(uint i=0;i<new_owners.length;i++){
            address owner = new_owners[i];
            require(owner!=address(0));
            require(isOwner[owner]!=true,"address exist!");
            owners.push(owner);
            isOwner[owner]=true;
        }
    }

    function getOwners()public view returns(address[] memory){
        return owners;
    }

    function getTransaction(uint index_tx)public view returns(Transaction memory){
        return transactions[index_tx];
    }

    function getTransactionNumber()public view returns(uint){
        return transactions.length;
    }
}
