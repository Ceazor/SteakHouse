// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SteakHouse} from "src/steakHouse.sol";
import {SteakHouseFeeCollector} from "src/steakHouseFeeCollector.sol";

contract Deploy is Script {    

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("CASTA_P_KEY");

        vm.startBroadcast(deployerPrivateKey);

        ABACUS abacus = new ABACUS();

        vm.stopBroadcast();
    }
}
