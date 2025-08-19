// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import './interfaces/import './interfaces/ICNSFactory.sol';';
import './interfaces/import './interfaces/ICNSPair.sol';';
import './libraries/TransferHelper.sol';
import './libraries/CNSLibrary.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './interfaces/IWETH.sol';

contract CNSRouter {
    address public immutable factory;
    address public immutable WETH;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'CNSRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    // **** ADD LIQUIDITY ****
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        if (ICNSFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            ICNSFactory(factory).createPair(tokenA, tokenB);
        }
        address pair = ICNSFactory(factory).getPair(tokenA, tokenB);
        (amountA, amountB) = _calculateAmounts(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, pair);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = ICNSPair(pair).mint(to);
    }

    function _calculateAmounts(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address pair
    ) private view returns (uint amountA, uint amountB) {
        (uint reserveA, uint reserveB,) = ICNSPair(pair).getReserves();
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = CNSLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'CNSRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = CNSLibrary.quote(amountBDesired, reserveB, reserveA);
                require(amountAOptimal >= amountAMin, 'CNSRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = ICNSFactory(factory).getPair(tokenA, tokenB);
        ICNSPair(pair).transferFrom(msg.sender, pair, liquidity);
        (amountA, amountB) = ICNSPair(pair).burn(to);
        require(amountA >= amountAMin, 'CNSRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'CNSRouter: INSUFFICIENT_B_AMOUNT');
    }

    // **** SWAP ****
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensure(deadline) returns (uint[] memory amounts) {
        amounts = CNSLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'CNSRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(path[0], msg.sender, CNSLibrary.pairFor(factory, path[0], path[1]), amounts[0]);
        _swap(amounts, path, to);
    }

    function _swap(uint[] memory amounts, address[] memory path, address _to) private {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = CNSLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? CNSLibrary.pairFor(factory, output, path[i + 2]) : _to;
            ICNSPair(CNSLibrary.pairFor(factory, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
}
