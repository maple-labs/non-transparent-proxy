// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.7;

interface INonTransparentProxy {

    /**
     *  @dev   A new implementation address was set.
     *  @param oldImplementationAddress_ The address of the old implementation.
     *  @param newImplementationAddress_ The address of the new implementation.
     */
    event ImplementationSet(address indexed oldImplementationAddress_, address indexed newImplementationAddress_);

    /**
     *  @dev   Sets the implementation address.
     *  @param newImplementation_ The address to set the implementation to.
     */
    function setImplementation(address newImplementation_) external;

}
