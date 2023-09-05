// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * ERC20 interface with mint, burn, and attached onchainData support.
 *
 * The inclusion of a "data" argument on each external method allows it to write
 * extra onchainData to the chain alongside each token transaction, in order to correlate it with
 * other on- and off-chain events.
 */
interface IERC20WithData is IERC165 {

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    // event TransferWithData(address indexed from, address indexed to, uint256 value, string onchainData);

    function mintToken(
        address to,
        uint256 amount,
        string calldata onchainData
    ) external;

    function transferWithData(
        address from,
        address to,
        uint256 amount,
        string calldata onchainData
    ) external;

    function burnWithData(
        address from,
        uint256 amount,
        string calldata onchainData
    ) external;
}
