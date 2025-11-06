// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";


contract FundMeTest is Test {

    uint256 number = 1;
    FundMe fundme;
    
    
    function setUp() external {
        fundme = new FundMe();
        number = 5 ;
    }

    function testExample() external {
        console.log("Number is:", number);
        assertEq(number, 5);
    }

    function testMinumumUsd() public{
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        assertEq(fundme.getOwner() ,address(this));
    }
    function testPriceFeedVersion() public {
    
        assertEq(fundme.getVersion() , 4);
    }
}