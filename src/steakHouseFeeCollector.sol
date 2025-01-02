// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import 'openzeppelin-contracts/contracts/utils/math/Math.sol';
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "src/steakHouse.sol";

// Gauges are used to incentivize pools, they emit reward tokens over 7 days for staked LP tokens
contract SteakHouseFeeCollector{

    address public salt;
    address public pepper;
    address public steakHouse;
    address public steak;

    address public team;
    bool public init;

    constructor(address _team) {
        team = _team;
    }   

    function initFeeCollector(address _steakHouse) public {
        require(msg.sender == team, 'only team');
        require(!init, 'already init');

        steakHouse = _steakHouse;
        steak = SteakHouse(steakHouse).stake();
        salt = SteakHouse(steakHouse).rewards(0);
        pepper = SteakHouse(steakHouse).rewards(1);
        init = true;
    }

    function changeTeam(address _newTeam) public {
        require(msg.sender == team, 'only team');
        team = _newTeam;
        emit TeamChanged(team);

    }

    function seasonTheSteak() public {
        transferPepperToGauge();
        transferSaltToGauge();
    }

    function transferSaltToGauge() public {
            require(checkSaltShaker() == true, 'need more salt');  // we are sending rewards only if we have more then the current rewards in the steakHouse
            
            uint256 saltCollected = IERC20(salt).balanceOf(address(this));

            IERC20(salt).approve(steakHouse, saltCollected);
            SteakHouse(steakHouse).notifyRewardAmount(salt, saltCollected);
            
    }

    function transferPepperToGauge() public {
            require(checkPepperShaker() == true , 'need more pepper');  // we are sending rewards only if we have more then the current rewards in the steakHouse

            uint256 pepperCollected = IERC20(pepper).balanceOf(address(this));
    
            IERC20(pepper).approve(steakHouse, pepperCollected);
            SteakHouse(steakHouse).notifyRewardAmount(pepper, pepperCollected);
    }            


    function checkSaltShaker() public view returns (bool){
        uint256 saltCollected = IERC20(salt).balanceOf(address(this));
        uint256 leftRewards = SteakHouse(steakHouse).left(salt);
            if(saltCollected > leftReward){
            return true;
            }
    }
    function checkPepperShaker() public view returns (bool){
        uint256 pepperCollected = IERC20(pepper).balanceOf(address(this));
        uint256 leftRewards = SteakHouse(steakHouse).left(pepper);
            if(pepperCollected > leftRewards){
            return true;
            }    
    }


    function sweepTokens(address _tokenToSweep, address _to) public {
        require(msg.sender == team, 'only team');
        require(_tokenToSweep != salt && _tokenToSweep != pepper);

        uint256 _bal = IERC20(_tokenToSweep).balanceOf(address(this));
        IERC20(_tokenToSweep).transferFrom(address(this), _to, _bal);

    }

    
}