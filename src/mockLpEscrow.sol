// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import 'openzeppelin-contracts/contracts/utils/math/Math.sol';
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import 'src/interfaces/ILpEscrow.sol';

// Gauges are used to incentivize pools, they emit reward tokens over 7 days for staked LP tokens
contract MockLpEscrow is  ILpEscrow{

    address public salt;
    address public pepper;
    address public feeRecipient;

    constructor(address _salt, address _pepper, address _feeCollector) {
        salt = _salt;
        pepper = _pepper;
        feeRecipient = _feeCollector;
    }

    function collectAndDistributeFees() external {
        uint256 saltBal = IERC20(salt).balanceOf(address(this));
        uint256 pepperBal = IERC20(pepper).balanceOf(address(this));

        IERC20(salt).transfer(feeRecipient, saltBal);
        IERC20(pepper).transfer(feeRecipient, pepperBal);


    }


}