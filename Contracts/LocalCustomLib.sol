// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

library customLib {
    address constant owner = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

    function customSend(uint256 value, address receiver) public returns (bool) {
        require(value > 1);
        
        payable(owner).transfer(1);
        
        (bool success,) = payable(receiver).call{value: value-1}("");
        return success;
    }
}
