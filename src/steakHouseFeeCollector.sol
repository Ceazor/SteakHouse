// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import 'openzeppelin-contracts/contracts/utils/math/Math.sol';
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import 'src/interfaces/IGauge.sol';

// Gauges are used to incentivize pools, they emit reward tokens over 7 days for staked LP tokens
contract SteakHouseFeeCollector{

    address public fee1;
    address public fee2;
    address public steakHouse;
    address public team;


    constructor(address _fee1, address _fee2, address _steakHouse, address _team) {
        fee1 = _fee1;
        fee2 = _fee2;
        steakHouse = _steakHouse;
        team = _team;

    }

    function _transferFee1ToGauge() internal {
        uint256 fee1Collected = IERC20(fee1).balanceOf(address(this));
        uint256 leftRewards = IGauge(steakHouse).left(fee1);

            if(fee1Collected > leftRewards) { // we are sending rewards only if we have more then the current rewards in the steakHouse
                IERC20(fee1).approve(steakHouse, fee1Collected);
                IGauge(steakHouse).notifyRewardAmount(fee1, fee1Collected);
            }
    }


    function sweepTokens(address _tokenToSweep, address _to) public {
        require(msg.sender == team, 'only team');
        require(_tokenToSweep != fee1 && _tokenToSweep != fee2);

        uint256 _bal = IERC20(_tokenToSweep).balanceOf(address(this));
        IERC20(_tokenToSweep).transferFrom(address(this), _to, _bal);

    }

    
}