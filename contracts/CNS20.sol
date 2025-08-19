// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract AdvancedCNS20 is ERC20, ERC20Snapshot, Ownable, Pausable {
    uint256 public transferFeeBps = 50; // 0.5% fee
    address public feeRecipient;
    mapping(address => bool) public isFeeExempt;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address _feeRecipient
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        feeRecipient = _feeRecipient;
        isFeeExempt[msg.sender] = true;
    }

    function setFeeBps(uint256 bps) external onlyOwner {
        require(bps <= 1000, "Max 10%");
        transferFeeBps = bps;
    }

    function setFeeRecipient(address recipient) external onlyOwner {
        feeRecipient = recipient;
    }

    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
    }

    function snapshot() external onlyOwner {
        _snapshot();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override whenNotPaused {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || transferFeeBps == 0) {
            super._transfer(sender, recipient, amount);
        } else {
            uint256 fee = (amount * transferFeeBps) / 10000;
            uint256 amountAfterFee = amount - fee;
            super._transfer(sender, feeRecipient, fee);
            super._transfer(sender, recipient, amountAfterFee);
        }
    }
}
