// SPDX-License-Identifier: MIT 


pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DecentralizedStableCoinTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config; 

    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;

    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;
    address public user = address(1);
    address public owner; 
    address public badUser = address(0);

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    uint256 public constant LIQUIDATION_THRESHOLD = 50;



    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, ,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(user, STARTING_USER_BALANCE);

        owner = address(dsce);
    }

    function testBurnMustBeMoreThanZero() public {
        vm.startPrank(owner);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.burn(0);
        vm.stopPrank();
    }

    function testBalanceMustBeMoreThanBurnAmount() public {
        vm.startPrank(owner);
        dsc.mint(owner, 1);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__BurnAmountExceedsBalance.selector);
        dsc.burn(2);
        vm.stopPrank();
    }

    function testNotZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__NotZeroAddress.selector);
        dsc.mint(badUser, 4);
        vm.stopPrank();
    }

    function testMustMintMoreThanZero() public {
        vm.startPrank(owner);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.mint(user, 0);
        vm.stopPrank();
    }

    function testSuccessfulBurn() public { 
        uint256 expectedBalance = 5 ether;
        vm.startPrank(owner);
        dsc.mint(owner, 10 ether);
        dsc.burn(5 ether);
        uint256 actualBalance = dsc.balanceOf(owner);
        assertEq(actualBalance, expectedBalance);
        vm.stopPrank();
        
    }

    function testSuccessfulMint() public {
        uint256 expectedBalance = 10 ether;
        vm.startPrank(owner);
        dsc.mint(owner, 10 ether);
        uint256 actualBalance = dsc.balanceOf(owner);
        assertEq(expectedBalance, actualBalance);
        vm.stopPrank();
    }

     function testConstructor() public {
       
        assertEq(dsc.owner(), owner);

        
        assertEq(dsc.name(), "Decentralized StableCoin");
        assertEq(dsc.symbol(), "DSC");

    }
}