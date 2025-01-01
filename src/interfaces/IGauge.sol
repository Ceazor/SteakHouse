pragma solidity 0.8.20;

interface IGauge {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(address account, address[] memory tokens) external;
    function left(address token) external view returns (uint);
    function stake() external view returns (address);
}