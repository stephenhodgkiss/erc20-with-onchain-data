// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20WithData.sol";

/**
 * Example ERC20 token with mint, burn, and attached onchainData support.
 *
 * This contract demonstrates a very simple ERC20 fungible token. Notes on functionality:
 *   - the contract owner (ie deployer) is the only party allowed to mint
 *   - any party can approve another party to manage (ie transfer) a certain amount of their
 *     tokens (approving for MAX_INT gives an unlimited approval)
 *   - any party can burn their own tokens
 *   - decimals hard-coded to 18 (so 1 token is expressed as 1000000000000000000)
 *
 * The inclusion of a "data" argument on each external method allows it to write
 * extra onchainData to the chain alongside each token transaction, in order to correlate it with
 * other on- and off-chain events.
 *
 * This is a sample only and NOT a reference implementation.
 */
contract ERC20WithData is Context, Ownable, ERC165, ERC20, IERC20WithData {
    uint256 private _totalSupply;
    string private _data;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC20WithData).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*
     * Mint new tokens with the following validation:
     * 1. The contract address cannot be the recipient of minted tokens
     * 2. The maximum amount of tokens that can be minted is set to 5 billion,
     * assuming the current value of 6 decimal places
     */
    function mintToken(
        address to,
        uint256 amount,
        string calldata onchainData
    ) external onlyOwner {
        require(
            to != address(this),
            "Cannot mint new tokens to the contract address."
        );
        require(
            amount <= 500000000000000000,
            "ERC20: Mint amount exceeds maximum of 500000000000000000."
        );
        _data = onchainData;
        _mint(to, amount);
    }

    // A new function similar to transfer() but with the additional onchainData variable
    // It also explicity references the new versions of 'transfer' and 'transferFrom'
    function transferWithData(
        address from,
        address to,
        uint256 amount,
        string calldata onchainData
    ) external {
        _data = onchainData;
        if (from == _msgSender()) {
            ERC20WithData.transfer(to, amount);
        } else {
            address spender = _msgSender();
            _spendAllowance(from, spender, amount);
            ERC20WithData.transferFrom(from, to, amount);
        }
    }

    // A new function similar to burn() but with the additional onchainData variable
    function burnWithData(
        address from,
        uint256 amount,
        string calldata onchainData
    ) external {
        _data = onchainData;
        require(from == _msgSender(), "ERC20WithData: caller is not owner");
        _burn(from, amount);
    }

    // Override the function so that it sets the decimal places to 6
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    // Override the function so that it ignores the amount at param #2
    // Instead always use the max value for a uint256
    function approve(address spender, uint256) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, type(uint256).max);
        emit Approval(owner, spender, type(uint256).max);
        return true;
    }

    // Remove the function and override it to do nothing
    function increaseAllowance(
        address,
        uint256
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }

    // Remove the function and override it to do nothing
    function decreaseAllowance(
        address,
        uint256
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when "from" and "to are both non-zero, amount of "from"s tokens
     * has been transferred to "to".
     * - when "from" is zero, "amount" tokens have been minted for "to".
     * - when "to" is zero, "amount" of "from"s tokens have been burned.
     * - "from" and "to" are never both zero.
     *
     * To learn more about hooks, head to https://docs.openzeppelin.com/contracts/4.x/extending-contracts
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        
        super._afterTokenTransfer(from, to, amount); // Call parent hook

        // create event passing in global variable _data
        emit TransferWithData(from, to, amount, _data);
    }
}
