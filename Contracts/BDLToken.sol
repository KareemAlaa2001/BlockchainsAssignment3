// SPDX-License-Identifier: AFL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract BDLToken {

    address private immutable owner;
    uint private immutable contractBalanceOffset;

    address private constant customLibAddress = 0xc0b843678E1E73c090De725Ee1Af6a9F728E2C47;
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
        contractBalanceOffset = address(this).balance;
        tokenPrice = 1;
        lock = false;
    }

    //  protects against cross-functional re-entrancy attacks
    modifier mutexLock() {
        require(!lock, "Hello 9-1-1? This dude just tried to pull a DAO - wait what do you mean you don't support decentralised crime?");
        lock = true;
        _;
    }

    /*  a function via which a user purchases {amount} number of tokens by paying the equivalent price in wei; if the purchase is successful, 
    the function returns a boolean value (true) and emits an event Purchase with the buyer’s address and the purchased amount   */

    function buyToken(uint256 amount) public payable mutexLock() returns (bool) {
        //  checks
        //  Check message value matches the amount sent
        require(msg.value == tokenPrice * amount, "Check your maths G, u sent the wrong amount");

        //  effects
        tokenBalances[msg.sender] += amount;
        numTokensInCirculation += amount;

        //  interactions
        lock = false;
        emit Purchase(msg.sender, amount);
        return true;
    }

    //  a function that transfers amount number of tokens from the account of the transaction’s sender to the recipient; 
    //  if the transfer is successful, the function returns a boolean value (true) and emits an event Transfer, with the sender’s and receiver’s addresses and the transferred amount
    function transfer(address recipient, uint256 amount) public mutexLock() returns (bool) {
        require(tokenBalances[msg.sender] >= amount, "HAHA you're broke!");

        tokenBalances[msg.sender] -= amount;
        tokenBalances[recipient] += amount;

        lock = false;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //  a function via which a user sells amount number of tokens and receives from the contract tokenPrice wei for each sold token; 
    //  if the sell is successful, the sold tokens are destroyed, 
    //  the function returns a boolean value (true) and emits an event Sell with the seller’s address and the sold amount of tokens
    function sellToken(uint256 amount) public mutexLock() returns (bool) {
        require(tokenBalances[msg.sender] >= amount, "I don't think you have the facilities for that big man");

        tokenBalances[msg.sender] -= amount;
        numTokensInCirculation -= amount;

        CustomLib myCustomLib = CustomLib(customLibAddress);
        myCustomLib.customSend(amount * tokenPrice, msg.sender);

        lock = false;
        emit Sell(msg.sender, amount);
        return true;
    } 
    
    //  a function via which the contract’s creator can change the tokenPrice; 
    //  if the action is successful, the function returns a boolean value (true) and emits an event Price with the new price 
    //  (Note: make sure that, whenever the price changes, the contract’s funds suffice so that all tokens can be sold for the updated price)
    function changePrice(uint256 price) public mutexLock() returns (bool) {
        //  require message sender to be conract creator
        require(msg.sender == owner, "I've never seen this man before in my life");
        require(numTokensInCirculation * price > contractBalance(), "Who do you think you are, the federal reserve?!");

        tokenPrice = price;

        lock = false;
        emit Price(price);
        return true;
    } 

    //  a view that returns the amount of tokens that the user owns
    function getBalance() public view returns (uint) {
        return tokenBalances[msg.sender];
    }

    function contractBalance() private view returns (uint) {
        return address(this).balance - contractBalanceOffset;
    }
}

abstract contract CustomLib {

    function customSend(uint256 value, address receiver) public virtual returns (bool);
}