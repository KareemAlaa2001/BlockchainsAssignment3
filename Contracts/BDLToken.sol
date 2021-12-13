// SPDX-License-Identifier: AFL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract BDLToken {

    uint tokenPrice;    // a uint256 that defines the price of your token in wei; each token can be purchased with tokenPrice wei
  
    event Purchase(address buyer, uint256 amount);  // an event that contains an address and a uint256
    event Transfer(address sender, address receiver, uint256 amount); // an event that contains two addresses and a uint256
    event Sell(address seller, uint256 amount); // an event that contains an address and a uint256
    event Price(uint256 price); // an event that contains a uint256

    /*  a function via which a user purchases amount number of tokens by paying the equivalent price in wei; if the purchase is successful, 
    the function returns a boolean value (true) and emits an event Purchase with the buyer’s address and the purchased amount   */
    function buyToken(uint256 amount) public {

    }

    //  a function that transfers amount number of tokens from the account of the transaction’s sender to the recipient; 
    //  if the transfer is successful, the function returns a boolean value (true) and emits an event Transfer, with the sender’s and receiver’s addresses and the transferred amount
    function transfer(address recipient, uint256 amount) public {

    }

    //  a function via which a user sells amount number of tokens and receives from the contract tokenPrice wei for each sold token; 
    //  if the sell is successful, the sold tokens are destroyed, 
    //  the function returns a boolean value (true) and emits an event Sell with the seller’s address and the sold amount of tokens
    function sellToken(uint256 amount) public {

    } 
    
    //  a function via which the contract’s creator can change the tokenPrice; 
    //  if the action is successful, the function returns a boolean value (true) and emits an event Price with the new price 
    //  (Note: make sure that, whenever the price changes, the contract’s funds suffice so that all tokens can be sold for the updated price)
    function changePrice(uint256 price) public {

    } 
    
    //  a view that returns the amount of tokens that the user owns
    function getBalance() public view {
        
    }
}