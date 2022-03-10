// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Fly} from "./FLY.sol";

/**
@title Basic Lending Contract
@notice This is a smart contract - a program that can be deployed into Ethereum blockchain
@author Aiman Nazmi
*/

contract BasicLending {
    // @notice Struct to store loan terms
    struct Terms {
        uint256 loanFlyAmount;
        uint256 feeFlyAmount;
        uint256 ethCollateralAmount;
    }

    Terms public terms;

    // 1656879049

    // @notice Enum representing loan state
    enum LoanState {Created, Funded, Taken}
    LoanState public state;

    // @notice Address of lender
    address public lender;

    // @notice Address of borrower
    address public borrower;

    // @notice Address of Fly
    address public flyAddress;

    // @notice Time to repay
    uint256 public repayTimestamp;

    // @notice Constructor to set loan terms, Fly address
    constructor(Terms memory _terms, address _flyAddress, uint _time) {
        terms = _terms;
        flyAddress = _flyAddress;
        lender = msg.sender;
        state = LoanState.Created;
        repayTimestamp = block.timestamp + _time;
    }

    // @notice Modifier to ensure loan state is as per expected
    modifier onlyInState(LoanState expectedState) {
        require(state == expectedState, "Not allowed in this state");
        _;
    }

    // @notice Function for lender to fund loan
    function fundLoan() public onlyInState(LoanState.Created) {
        state = LoanState.Funded;
        Fly(flyAddress).transferFrom(msg.sender, address(this), terms.loanFlyAmount);
    }

    // @notice Function for borrower to take out loan
    function takeLoanAndAcceptLoanTerms() public payable onlyInState(LoanState.Funded) {
        require(msg.value >= terms.ethCollateralAmount, "Insufficient collateral Amount");
        borrower = msg.sender;
        state = LoanState.Taken;
        Fly(flyAddress).transfer(borrower, terms.loanFlyAmount);
    }

    // @notice Function for borrower to repay
    function repay() public onlyInState(LoanState.Taken) {
        require(msg.sender == borrower, "Only the borrower can repay the loan");
        Fly(flyAddress).transferFrom(msg.sender, address(this), terms.loanFlyAmount + terms.feeFlyAmount);
        selfdestruct(payable(borrower));
    }

    // @notice Function for lender to liquidate collateral
    function liquidate() public onlyInState(LoanState.Taken) {
        require(msg.sender == lender, "Only lender can liquidate the loan");
        require(block.timestamp >= repayTimestamp, "Cannot liquidate before the loan is due");
        selfdestruct(payable(lender));
    }

    // @notice Function to view collateral balance
    function viewCollBalance() view public returns (uint) {
        return address(this).balance;
    }

    // @notice Function to view contract's address once user called self-destruct
    function viewAddress() view public returns (address) {
        return address(this);
    }

}
