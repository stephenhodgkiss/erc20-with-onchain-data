// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * ERC20 interface with mint, burn, and attached data support.
 *
 * The inclusion of a "data" argument on each external method allows it to write
 * extra data to the chain alongside each token transaction, in order to correlate it with
 * other on- and off-chain events.
 */
interface IERC20WithData is IERC165 {
    function mintWithData(
        uint256 amount,
        string calldata data
    ) external;

    function transferWithData(
        address from,
        address to,
        uint256 amount,
        string calldata data
    ) external;

    function burnWithData(
        address from,
        uint256 amount,
        string calldata data
    ) external;
}
