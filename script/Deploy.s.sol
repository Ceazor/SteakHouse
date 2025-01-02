// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {SteakHouse} from "src/steakHouse.sol";
import {SteakHouseFeeCollector} from "src/steakHouseFeeCollector.sol";

contract Deploy is Script {  

    address constant team = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2; // ceazor.eth for now
    address constant steak = 0x699675204aFD7Ac2BB146d60e4E3Ddc243843519; // NOTE!!!!! deploy coin on makeFun for address
    address constant cdxUSD = 0xC0D3700000987C99b3C9009069E4f8413fD22330;

    //When deploying token on Make.Fun you need to set the fee collector so the order of deployment must be
    // FeeCollector
    // Token on makeFun
    // Steakhouse gauge
    // Init Steakhouse - this first cause feeCollect pull addresses from steakHouse
    // Init FeeCollect



    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        new SteakHouseFeeCollector(team);
        new SteakHouse(team);

        vm.stopBroadcast();
    }

}
