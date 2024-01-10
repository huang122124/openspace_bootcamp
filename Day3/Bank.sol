// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Bank{
    mapping(address => uint) public balance;
    address public owner;
    address[3] public top3_addr;
    // uint constant TOP_NUMBER = 3;


    constructor(){
        owner = msg.sender;
    }

    modifier only_Owner(){
        require(msg.sender == owner,"not owner!");
        _;
    }

    receive() external payable { 
        balance[msg.sender] += msg.value;
        if(top3_addr[0]!=msg.sender&&top3_addr[1]!=msg.sender&&top3_addr[2]!=msg.sender){
            if(top3_addr[0]==address(0)){
                top3_addr[0] = msg.sender;
            }else if (top3_addr[1]==address(0)){
                top3_addr[1] = msg.sender;
            }else if (top3_addr[2]==address(0)){
                top3_addr[2] = msg.sender;
                array_top3(top3_addr);
            }else {
                //top3_addr已填充
                if(balance[top3_addr[2]]<msg.value){
                    if(balance[top3_addr[1]]<msg.value){
                        if(balance[top3_addr[0]]<msg.value){
                            top3_addr[2]=top3_addr[1];
                            top3_addr[1]=top3_addr[0];
                            top3_addr[0]=msg.sender;
                        }else {
                            top3_addr[2]=top3_addr[1];
                            top3_addr[1]=msg.sender;
                        }
                    }else {
                        top3_addr[2] = msg.sender;
                    }
                }
            }
        }
    }

    function withdraw() external only_Owner(){
        payable(msg.sender).transfer(address(this).balance);
    }
//[22,33,55,12,9,28]
    function array_top3(address[3] storage x) internal{
        for(uint i=0;i<x.length-2;i++){
            for(uint j=i;j<x.length-1;j++){
                if(balance[x[i]]<balance[x[j+1]]){
                    address tmp = x[i];
                    x[i] = x[j+1];
                    x[j+1] = tmp;
                }
            }
        }
    }

    function get_balance() public view returns (uint){
        return address(this).balance;
    }

    function get_top3() public view returns (address,address,address,uint,uint,uint){
        return (top3_addr[0],top3_addr[1],top3_addr[2],
        balance[top3_addr[0]],balance[top3_addr[1]],balance[top3_addr[2]]);
    }
}