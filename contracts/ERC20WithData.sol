// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
pragma abicoder v2;

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
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    address public contractOwner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        contractOwner = msg.sender;
    }

    // Getter function for contractOwner variable
    function getContractOwner() public view returns (address) {
        return contractOwner;
    }

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
     * 2. The contract owner address cannot be the recipient of minted tokens
     * 3. The maximum amount of tokens that can be minted is set to 5 billion,
     * assuming the current fixed value of 6 decimal places
     */
    function mintToken(address to, uint256 amount) external onlyOwner {
        require(
            to != address(this),
            "Cannot mint new tokens to the contract address."
        );
        require(
            to != contractOwner,
            "Cannot mint new tokens to the contract owner."
        );
        require(
            amount <= 500000000000000000,
            "ERC20: Mint amounts exceeds maximum of 500000000000000000."
        );
        _mint(to, amount);
    }

    function transferWithData(
        address from,
        address to,
        uint256 amount,
        string calldata data
    ) external override {
        if (from == _msgSender()) {
            transfer(to, amount);
        } else {
            address spender = _msgSender();
            _spendAllowance(from, spender, amount);
            transferFrom(from, to, amount, data);
        }
    }

    function burnWithData(
        address from,
        uint256 amount,
        string calldata
    ) external override {
        require(from == _msgSender(), "ERC20WithData: caller is not owner");
        _burn(from, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function approve(address spender, uint256) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, type(uint256).max);
        emit Approval(owner, spender, type(uint256).max);
        return true;
    }

    // Remove the functions and override it to do nothing
    function increaseAllowance(
        address,
        uint256
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }

    function decreaseAllowance(
        address,
        uint256
    ) public virtual override returns (bool) {
        // Do nothing
        return true;
    }

    function transfer(
        address to,
        uint256 amount,
        string calldata data
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _transferWithData(owner, to, amount, data);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount,
        string calldata data
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transferWithData(from, to, amount, data);
        return true;
    }

    function _transferWithData(
        address from,
        address to,
        uint256 amount,
        string calldata data
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit TransferWithData(from, to, amount, data);

        _afterTokenTransfer(from, to, amount);
    }
}
