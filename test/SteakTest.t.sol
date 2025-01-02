pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "src/steakHouse.sol";
import "src/steakHouseFeeCollector.sol";


contract SteakTest is Test{
    uint256 constant TOKEN_1 = 1e18;
    uint256 constant TOKEN_100K = 1e23; // 1e5 = 100K tokens with 18 decimals
    uint256 constant TOKEN_1M = 1e24; // 1e6 = 1M tokens with 18 decimals
    uint256 constant private ONE_DAY = 86400;
    uint256 constant internal ONE_WEEK = ONE_DAY * 7;
    uint256 constant internal FIFTY_TWO_WEEKS = 52 * ONE_WEEK;

    address constant ceazor = 0x3c5Aac016EF2F178e8699D6208796A2D67557fe2;
    address constant bill = 0xA67D2c03c3cfe6177a60cAed0a4cfDA7C7a563e0;
    address constant dan = 0x57163Ac75E95f3690be63CA43F6f27bb38B48453;
    address constant fakeMFFees = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;
    address cdxUSDAddy;
    address steakAddy;


    MockERC20 cdxUSD;
    MockERC20 STEAK;
    SteakHouse steakHouse;
    SteakHouseFeeCollector steakHouseFeeCollector;




    function setUp() public {
        deployContracts();
        deployAndMintCoins();
        initContracts();

    }

    function deployContracts() public {
        steakHouse = new SteakHouse(ceazor);
        steakHouseFeeCollector = new SteakHouseFeeCollector(ceazor);
    }
    function deployAndMintCoins() public {
        cdxUSD = new MockERC20("cdxUSD", "cdxUSD", 18);
        STEAK = new MockERC20("STEAK", "STEAK", 18);
        cdxUSDAddy = address(cdxUSD);
        steakAddy = address(STEAK);
        STEAK.mint(bill, TOKEN_1M);
        STEAK.mint(dan, TOKEN_100K);
        cdxUSD.mint(fakeMFFees, TOKEN_1 * 20);
        STEAK.mint(fakeMFFees, TOKEN_1 * 20);
    
    }  
    function initContracts() public {
        address[] memory saltAndPepper = new address[](2);
        saltAndPepper[0] = address(STEAK);
        saltAndPepper[1] = address(cdxUSD);
        
        vm.startPrank(ceazor);

        steakHouse.initStakeHouse(address(STEAK), saltAndPepper);
        steakHouseFeeCollector.initFeeCollector(address(steakHouse));
        vm.stopPrank();
    }
 
    function testDeposit() public {
        vm.startPrank(bill);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(bill, TOKEN_100K);

        assertEq(STEAK.balanceOf(bill), TOKEN_1M - TOKEN_100K);
    }

    function testWithdraw() public {
        vm.startPrank(bill);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(bill, TOKEN_100K);

        vm.warp(ONE_WEEK + 1);
        steakHouse.withdrawAll();

        assertEq(STEAK.balanceOf(bill), TOKEN_1M);
    }

    function testAddSaltAndPepper() public {
        vm.startPrank(fakeMFFees);
        STEAK.transfer(address(steakHouseFeeCollector), TOKEN_1);
        cdxUSD.transfer(address(steakHouseFeeCollector), TOKEN_1);
        vm.stopPrank();

        assertEq(STEAK.balanceOf(address(steakHouseFeeCollector)), TOKEN_1);
        assertEq(cdxUSD.balanceOf(address(steakHouseFeeCollector)), TOKEN_1);

        steakHouseFeeCollector.seasonTheSteak();
    }

    function testDepositAndRewardThenWithdraw() public {
        vm.startPrank(bill);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(bill, TOKEN_100K);
        vm.stopPrank();

        vm.startPrank(fakeMFFees);
        STEAK.transfer(address(steakHouseFeeCollector), TOKEN_1);
        cdxUSD.transfer(address(steakHouseFeeCollector), TOKEN_1);
        vm.stopPrank();

        steakHouseFeeCollector.seasonTheSteak();

        vm.warp(ONE_WEEK + 2);

        vm.startPrank(bill);

        address[] memory saltAndPepper = new address[](2);
        saltAndPepper[0] = address(STEAK);
        saltAndPepper[1] = address(cdxUSD);
        steakHouse.getReward(bill, saltAndPepper);
        steakHouse.withdrawAll();
        vm.stopPrank();

        assertGt(STEAK.balanceOf(bill), TOKEN_1M);
        assertGt(cdxUSD.balanceOf(bill), 0);

        assertLt(STEAK.balanceOf(bill), TOKEN_1M + TOKEN_1);
        assertLt(cdxUSD.balanceOf(bill), TOKEN_1);
    }

    function testMultiDepositAndRewardThenWithdraw() public {
        vm.startPrank(bill);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(bill, TOKEN_100K);
        vm.stopPrank();

        vm.startPrank(dan);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(dan, TOKEN_100K);
        vm.stopPrank();

        vm.startPrank(fakeMFFees);
        STEAK.transfer(address(steakHouseFeeCollector), TOKEN_1);
        cdxUSD.transfer(address(steakHouseFeeCollector), TOKEN_1);
        vm.stopPrank();

        steakHouseFeeCollector.seasonTheSteak();

        vm.warp(ONE_WEEK + 2);

        address[] memory saltAndPepper = new address[](2);
        saltAndPepper[0] = address(STEAK);
        saltAndPepper[1] = address(cdxUSD);

        vm.startPrank(bill);
        steakHouse.getReward(bill, saltAndPepper);
        steakHouse.withdrawAll();
        vm.stopPrank();

        vm.startPrank(dan);
        steakHouse.getReward(dan, saltAndPepper);
        steakHouse.withdrawAll();
        vm.stopPrank();

        assertGt(STEAK.balanceOf(bill), TOKEN_1M);
        assertGt(cdxUSD.balanceOf(bill), 0);
        assertGt(STEAK.balanceOf(dan), TOKEN_100K);
        assertGt(cdxUSD.balanceOf(dan), 0);
        assertEq(cdxUSD.balanceOf(bill), cdxUSD.balanceOf(dan));

    }

    function testMultiDepositReward2WeeksButOneWithdrawEarly() public {
        vm.startPrank(bill);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(bill, TOKEN_100K);
        vm.stopPrank();

        vm.startPrank(dan);
        STEAK.approve(address(steakHouse), TOKEN_100K);
        steakHouse.depositWithLock(dan, TOKEN_100K);
        vm.stopPrank();

        vm.startPrank(fakeMFFees);
        STEAK.transfer(address(steakHouseFeeCollector), TOKEN_1);
        cdxUSD.transfer(address(steakHouseFeeCollector), TOKEN_1);
        vm.stopPrank();

        steakHouseFeeCollector.seasonTheSteak();

        vm.warp(ONE_WEEK + 2);

        vm.startPrank(bill);
        steakHouse.withdrawAll();
        vm.stopPrank();

        vm.startPrank(fakeMFFees);
        STEAK.transfer(address(steakHouseFeeCollector), TOKEN_1);
        cdxUSD.transfer(address(steakHouseFeeCollector), TOKEN_1);
        vm.stopPrank();

        steakHouseFeeCollector.seasonTheSteak();

        vm.warp(ONE_WEEK + ONE_WEEK + 2);

        address[] memory saltAndPepper = new address[](2);
        saltAndPepper[0] = address(STEAK);
        saltAndPepper[1] = address(cdxUSD);

        vm.startPrank(bill);
        steakHouse.getReward(bill, saltAndPepper);
        vm.stopPrank();

        vm.startPrank(dan);
        steakHouse.getReward(dan, saltAndPepper);
        steakHouse.withdrawAll();
        vm.stopPrank();

        assertGt(STEAK.balanceOf(bill), TOKEN_1M);
        assertGt(cdxUSD.balanceOf(bill), 0);
        assertGt(STEAK.balanceOf(dan), TOKEN_100K);
        assertGt(cdxUSD.balanceOf(dan), 0);
        assertGt(cdxUSD.balanceOf(dan), cdxUSD.balanceOf(bill));
    }
 
}
