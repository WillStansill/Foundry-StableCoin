// SPDX-License-Identifier: MIT 


pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract DSCEngineTest is Test{
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

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant MIN_HEALTH_FACTOR = 1e18;
    uint256 public constant LIQUIDATION_THRESHOLD = 50;



    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, ,) = config.activeNetworkConfig();

        ERC20Mock(weth).mint(user, STARTING_USER_BALANCE);
    }

    /////////////////////
    // Constructor Test//
    /////////////////////
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds()  public {
        tokenAddresses.push(weth);
        priceFeedAddresses.push(ethUsdPriceFeed);
        priceFeedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
    }


    ///////////////
    // Price Test//
    ///////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        uint256 expectedUsd = 30000e18;
        uint256 actualUsd = dsce.getUsdValue(weth, ethAmount);
        assertEq(expectedUsd, actualUsd);
    }
    function testGetTokenAmountFromUsd() public {
        uint256 usdAmount = 100 ether;
        //2000 / ETH, $100
        uint256 expectedWeth = 0.05 ether;
        uint256 actualWeth = dsce.getTokenAmountFromUsd(weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    ///////////////////////////
    // depositCollateral Test//
    ///////////////////////////

    function testRevertsIfCollateralZero() public {
        vm.startBroadcast(user);
        ERC20Mock(weth).approve(address(dsce), amountCollateral);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);

    }

    function testDepositCollateralAllowsToken () public {
        ERC20Mock ranToken = new ERC20Mock();
        vm.startPrank(user);
        vm.expectRevert(DSCEngine.DSCEngine__NotAllowedToken.selector);
        dsce.depositCollateral(address(ranToken), amountCollateral);
        vm.stopPrank();
    }

    modifier depositedCollateral() {
        vm.startPrank(user);
        ERC20Mock(weth).approve(address(dsce), amountCollateral);
        dsce.depositCollateral(weth, amountCollateral);
        vm.stopPrank();
        _;
    }
    modifier depositedCollateralAndMintDsc() {
        vm.startPrank(user);
        ERC20Mock(weth).approve(address(dsce), amountCollateral);
        dsce.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
        _;
    }

    function testCanDepositCollateralAndGetAccountInfo() public depositedCollateral{
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(user);

        uint256 expectedTotalDscMinted = 0;
        uint256 expectedDepositAmount = dsce.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(amountCollateral, expectedDepositAmount);
    }

    function testDscMintsAfterCollateralDeposited() public depositedCollateral{
        uint256 amountDscToMint = 5 ether;
        vm.prank(user);
        dsce.mintDsc(amountDscToMint);
        uint256 userDscBalance = dsc.balanceOf(user);
        assertEq(userDscBalance, amountDscToMint);
        vm.stopPrank();
    }

    // Testing Burn Function 

    function testCanBurnDsc() public depositedCollateralAndMintDsc{
        vm.startPrank(user);
        dsc.approve(address(dsce), amountToMint);
        dsce.burnDsc(amountToMint);
        vm.stopPrank();

        uint256 userBalance = dsc.balanceOf(user);
        assertEq(userBalance, 0);
    }

    function testCantBurnMoreThanUserHas() public {
        vm.startPrank(user);
        vm.expectRevert();
        dsce.burnDsc(1);
    }

    function testCollateralIsRedeemed() public depositedCollateralAndMintDsc {
        vm.startPrank(user);
        dsc.approve(address(dsce), amountToMint);

        uint256 initialCollateralValueInUsd = dsce.getAccountCollateralValueInUsd(user);

        dsce.redeemCollateralForDsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();

        uint256 userCollateralBalance = dsce.getAccountCollateralValueInUsd(user);
        uint256 userBalance = dsc.balanceOf(user);
        assertEq(userCollateralBalance, initialCollateralValueInUsd - dsce.getUsdValue(weth, amountCollateral));
        assertEq(userBalance, 0);
    }


    //Testing Liquidation 

    function testLiquidateRevertsIfHealthFactorIsHealthy() public {

        vm.startPrank(user);
        dsc.approve(address(dsce), amountToMint);   
        uint256 debtToCover = 50 ether; 
        vm.expectRevert(DSCEngine.DSCEngine__HealthFactorOk.selector);
        dsce.liquidate(weth, user, debtToCover);
        vm.stopPrank();
        }

    


}