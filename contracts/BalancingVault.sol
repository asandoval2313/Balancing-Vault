// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol';

interface DepositableERC20 is IERC20 {
    function deposit() external payable;
}

contract BalancingVault {

    /*Kovan Addresses*/
    address public daiAddress = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address public wethAddress = 0xdFCeA9088c8A88A76FF74892C1457C17dfeef9C1;   
    address public uinswapV3QuoterAddress = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address public uinswapV3RouterAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public chainLinkETHUSDAddress = 0x9326BFA02ADD2366b30bacB125260Af641031331;
    address public owner; 

    uint public ethPrice;

    using SafeERC20 for IERC20;
    using SafeERC20 for DepositableERC20;

    IERC20 daiToken = IERC20(daiAddress);
    DepositableERC20 wethToken = DepositableERC20(wethAddress);
    IQuoter quoter = IQuoter(uinswapV3QuoterAddress);

    constructor() {
        console.log("Deploying BalancingVault");
        owner = msg.sender;
    }

    function getDaiBalance() public view returns(uint) {
        return daiToken.balanceOf(address(this));
    } 

    function getWethBalance() public view returns(uint) {
        return wethToken.balanceOf(address(this));
    }

    function getTotalBalance() public view returns(uint) {
        require(ethPrice > 0, 'ETH price has not been set');

        uint daiBalance = getDaiBalance();
        uint wethBalance = getWethBalance();
        uint wethToUsd = wethBalance * ethPrice;
        return daiBalance + wethToUsd;
    }
    
    function updateEthPrice() public returns(uint) {

    }

    function closeAccount() public {
        uint daiBalance = getDaiBalance();
        if (daiBalance > 0) {
            daiToken.safeTransfer(owner, daiBalance);
        }

        uint wethBalance = getWethBalance();
        if (wethBalance > 0) {
            wethToken.safeTransfer(owner, wethBalance);
        }
    }

}
