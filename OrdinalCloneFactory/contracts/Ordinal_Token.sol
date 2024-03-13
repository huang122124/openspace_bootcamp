// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract Ordinal_Token is ERC20Upgradeable{
    address public factory;
    

    event Mint(address, uint);

    function init(
        string memory _name,
        string memory _symbol
    ) public initializer {
        factory = _msgSender();
        __ERC20_init(_name, _symbol);
    }

    function mint(address minter,uint value) external{
        require(_msgSender() == factory,"caller is not factory!");
        _mint(minter, value);
    }
}
