// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/**
@title My token contract
@notice This is a smart contract - a program that can be deployed into Ethereum
@author Aiman Nazmi
*/

// @notice IERC20 contract from OpenZeppelin's library
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Fly is IERC20 {

    // @notice State variable of owner
    address public contractOwner;

    // @notice State variable to track total token supply
    uint public totalTokenSupply;

    // @notice State variables for token name and symbol
    string public name = "Fluidly";
    string public symbol = "FLY";

    // @notice State variable for decimal
    uint8 public decimal = 18;

    // @notice Mapping to track user's balance
    mapping(address => uint) balance;

    // @notice Mapping to track allowance
    mapping(address => mapping(address => uint)) totalAllowance;

    // @notice Constructor to set owner
    constructor() {
        contractOwner = msg.sender;
    }

    // @notice Function to view total token supply
    function totalSupply() external view override returns (uint256) {
        return totalTokenSupply;
    }

    // @notice Function to view balance of specific account
    // @param account Account to view its balance
    function balanceOf(address account) external view override returns (uint256) {
        return balance[account];
    }

    // @notice Function to transfer token to other user
    // @param to Address of recipient
    // @amount Amount of token to transfer
    function transfer(address to, uint256 amount) external override returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    // @notice Function to view total allowance allocated to spender
    // @param owner Address of token's owner
    // @param spender Address of spender's owner
    function allowance(address owner, address spender) external view override returns (uint256) {
        return totalAllowance[owner][spender];
    }

    // @notice Function to approve spender to spend on behalf of owner
    // @param spender Address of spender
    // @param amount Token amount to be given as allowance
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(balance[msg.sender] >= amount, "Insufficient amount for allowance");
        balance[msg.sender] -= amount;
        totalAllowance[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // @notice Function to allow spender to transfer on behalf of owner
    // @param from Address of owner
    // @param to Address of recipient
    // @param amount Token amount to be transferred
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(balance[from] >= amount, "Insufficient amount");
        balance[from] -= amount;
        balance[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // @notice Function to mint new token
    // @param _amount Amount of token to mint
    function mint(uint256 _amount) public returns (bool) {
        require(msg.sender == contractOwner, "Not contract owner");
        totalTokenSupply += _amount;
        balance[msg.sender] += _amount;
        return true;
    }

    // @notice Function to burn token
    // @param _amount Amount of token to burn
    function burn(uint256 _amount) public returns (bool) {
        require(msg.sender == contractOwner, "Not contract owner");
        totalTokenSupply -= _amount;
        balance[msg.sender] -= _amount;
        return true;
    }
}
