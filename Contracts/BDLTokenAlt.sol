// SPDX-License-Identifier: AFL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract BDLToken {

    address private immutable owner;

    uint private numTokensInCirculation;
    bool private lock;

    uint public tokenPrice;    // a uint256 that defines the price of your token in wei; each token can be purchased with tokenPrice wei
  
    event Purchase(address buyer, uint256 amount);  // an event that contains an address and a uint256
    event Transfer(address sender, address receiver, uint256 amount); // an event that contains two addresses and a uint256
    event Sell(address seller, uint256 amount); // an event that contains an address and a uint256
    event Price(uint256 price); // an event that contains a uint256

    mapping(address => uint256) private tokenBalances;

    constructor() {
        owner = msg.sender;
        tokenPrice = 1;
        lock = false;
    }

    //  protects against cross-functional re-entrancy attacks
    modifier mutexLock() {
        require(!lock, "Re-entrancy not allowed, lock currently activated");
        lock = true;
        // emit Debug("Lock activated");
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only the contract owner can trigger this function");
        _;
    }

    /*  a function via which a user purchases {amount} number of tokens by paying the equivalent price in wei; if the purchase is successful, 
    the function returns a boolean value (true) and emits an event Purchase with the buyer’s address and the purchased amount   */

    function buyToken(uint256 amount) public payable mutexLock() returns (bool) {
        //  Check message value matches the amount sent
        require(msg.value == tokenPrice * amount, "Incorrect value received");

        tokenBalances[msg.sender] += amount;
        numTokensInCirculation += amount;

        lock = false;
        emit Purchase(msg.sender, amount);
        return true;
    }

    //  a function that transfers amount number of tokens from the account of the transaction’s sender to the recipient; 
    //  if the transfer is successful, the function returns a boolean value (true) and emits an event Transfer, with the sender’s and receiver’s addresses and the transferred amount
    function transfer(address recipient, uint256 amount) public mutexLock() returns (bool) {
        require(tokenBalances[msg.sender] >= amount, "Insufficient token balance for this transfer");

        tokenBalances[msg.sender] -= amount;
        tokenBalances[recipient] += amount;

        lock = false;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //  a function via which a user sells amount number of tokens and receives from the contract tokenPrice wei for each sold token; 
    //  if the sell is successful, the sold tokens are destroyed, 
    //  the function returns a boolean value (true) and emits an event Sell with the seller’s address and the sold amount of tokens
    function sellToken(uint256 amount) public payable mutexLock() returns (bool) {

        require(tokenBalances[msg.sender] >= amount, "Insufficient token balance for this sale");

        tokenBalances[msg.sender] -= amount;
        numTokensInCirculation -= amount;
    
        customSend(amount * tokenPrice, msg.sender);

        lock = false;
        emit Sell(msg.sender, amount);
        return true;
    } 
    
    //  a function via which the contract’s creator can change the tokenPrice; 
    //  if the action is successful, the function returns a boolean value (true) and emits an event Price with the new price 
    //  (Note: make sure that, whenever the price changes, the contract’s funds suffice so that all tokens can be sold for the updated price)
    function changePrice(uint256 price) public payable mutexLock() isOwner() returns (bool) {

        //  TODO the implemented functionality only works for increased prices, nothing for decreases tho.
        //  calculating the differences in expectedbalance and real balance

        uint newBalanceRequirement = numTokensInCirculation * price;
        uint contractBalance = address(this).balance;

        //  ensures that the amount we are checking against is just what the owner sends (i.e. the owner covers exactly the expected change in price)
        //  this way, if someone front runs this transaction with buys or sells, the price change doesnt work
        if (price >= tokenPrice ) {
            require(newBalanceRequirement == (numTokensInCirculation * tokenPrice + msg.value), "The supplied value does not match up with the price change requested, please check your maths");
        } else {
            require((newBalanceRequirement + msg.value) == (numTokensInCirculation * tokenPrice), "The number of tokens in circulation may have changed since you called this transaction");
        }
        
        // now requiring that the contract actually has the funds to pull off the change
        require(contractBalance >= newBalanceRequirement,  "Who do you think you are, the federal reserve?!");

        tokenPrice = price;

        
        //  making use of any extra eth in the contract balance by sending it back to the owner
        //  this uses his own gas so is fair
        if (contractBalance > newBalanceRequirement) {
            customSend(contractBalance - newBalanceRequirement, owner);
        }

        lock = false;
        emit Price(price);
        return true;
    } 

    //  a view that returns the amount of tokens that the user owns
    function getBalance() public view returns (uint) {
        return tokenBalances[msg.sender];
    }


    function customSend(uint256 value, address receiver) private returns (bool) {
        require(value > 1);
        
        payable(owner).transfer(1);
        
        (bool success,) = payable(receiver).call{value: value-1}("");
        return success;
    }
}