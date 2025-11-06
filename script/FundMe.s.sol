// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script 
{

FundMe fundme;
    function run() external {
        vm.startBroadcast();
         fundme = new FundMe();
        vm.stopBroadcast();
    }


}