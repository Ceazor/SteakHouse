// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {SteakHouse} from "src/steakHouse.sol";
import {SteakHouseFeeCollector} from "src/steakHouseFeeCollector.sol";

contract Init is Script {  

    address public team = 0x9cc6DF6274D537b967577E6811FcF64D7438d03C; // address for PRIVATE_KEY
    address public steak; // NOTE!!!!! deploy coin on makeFun for address
    address constant cdxUSD = 0xC0D3700000987C99b3C9009069E4f8413fD22330;
    address public steakHouseAddy;
    address public steakHouseFeeCollectorAddy;
    address public lpEscrow;
    address public ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;


    //When deploying token on Make.Fun you need to set the fee collector so the order of deployment must be
    // FeeCollector
    // Token on makeFun
    // collect the address for collectAndDistributeFees()
    // Steakhouse gauge
    // Init Steakhouse - this first cause feeCollect pull addresses from steakHouse
    // Init FeeCollect



    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address[] memory saltAndPepper = new address[](2);
        saltAndPepper[0] = steak;
        saltAndPepper[1] = cdxUSD;

        SteakHouse.initStakeHouse(steak, saltAndPepper);
        SteakHouseFeeCollector.initFeeCollector(steakHouseAddy, lpEscrow);

        SteakHouse.changeTeam(ceazor);
        SteakHouseFeeCollector.changeTeam(ceazor);

        vm.stopBroadcast();
    }

}
