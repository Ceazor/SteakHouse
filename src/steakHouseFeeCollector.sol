// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import 'openzeppelin-contracts/contracts/utils/math/Math.sol';
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import 'src/interfaces/IGauge.sol';

// Gauges are used to incentivize pools, they emit reward tokens over 7 days for staked LP tokens
contract SteakHouseFeeCollector{

    address public salt;
    address public pepper;
    address public steakHouse;
    address public team;


    constructor(address _salt, address _pepper, address _steakHouse, address _team) {
        salt = _salt;
        pepper = _pepper;
        steakHouse = _steakHouse;
        team = _team;

    }

    function seasonTheSteak() public {
        transferPepperToGauge();
        transferSaltToGauge();
    }

    function transferSaltToGauge() public {
        uint256 saltCollected = IERC20(salt).balanceOf(address(this));
        uint256 leftRewards = IGauge(steakHouse).left(salt);

            if(saltCollected > leftRewards) { // we are sending rewards only if we have more then the current rewards in the steakHouse
                IERC20(salt).approve(steakHouse, saltCollected);
                IGauge(steakHouse).notifyRewardAmount(salt, saltCollected);
            }
    }

    function transferPepperToGauge() public {
        uint256 pepperCollected = IERC20(pepper).balanceOf(address(this));
        uint256 leftRewards = IGauge(steakHouse).left(pepper);

            if(pepperCollected > leftRewards) { // we are sending rewards only if we have more then the current rewards in the steakHouse
                IERC20(pepper).approve(steakHouse, pepperCollected);
                IGauge(steakHouse).notifyRewardAmount(pepper, pepperCollected);
            }
    }


    function checkSaltShaker() public view returns (uint){
        uint256 saltCollected = IERC20(salt).balanceOf(address(this));
        return saltCollected;
    }
    function checkPepperShaker() public view returns (uint){
        uint256 pepperCollected = IERC20(pepper).balanceOf(address(this));
        return pepperCollected;
    }


    function sweepTokens(address _tokenToSweep, address _to) public {
        require(msg.sender == team, 'only team');
        require(_tokenToSweep != salt && _tokenToSweep != pepper);

        uint256 _bal = IERC20(_tokenToSweep).balanceOf(address(this));
        IERC20(_tokenToSweep).transferFrom(address(this), _to, _bal);

    }

    
}