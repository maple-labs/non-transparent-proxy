// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { NonTransparentProxied } from "../contracts/NonTransparentProxied.sol";
import { NonTransparentProxy }   from "../contracts/NonTransparentProxy.sol";

import { TestUtils } from "../modules/contract-test-utils/contracts/test.sol";

contract NTPTestBase is TestUtils {

    address constant ADMIN     = address(1);
    address constant NOT_ADMIN = address(2);

    bytes32 constant ADMIN_SLOT          = bytes32(uint256(keccak256("eip1967.proxy.admin"))          - 1);
    bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    NonTransparentProxied implementation;

    function setUp() public virtual {
        implementation = new NonTransparentProxied();
    }

}

contract NTPConstructorTests is NTPTestBase {

    function test_constructor() external {
        address proxy = address(new NonTransparentProxy(ADMIN, address(implementation)));

        address adminStorage          = address(uint160(uint256(vm.load(proxy, ADMIN_SLOT))));
        address implementationStorage = address(uint160(uint256(vm.load(proxy, IMPLEMENTATION_SLOT))));

        assertEq(adminStorage,          ADMIN);
        assertEq(implementationStorage, address(implementation));

        assertEq(NonTransparentProxied(proxy).admin(),          ADMIN);
        assertEq(NonTransparentProxied(proxy).implementation(), address(implementation));
    }

}

contract NTPSetImplementationFailureTests is NTPTestBase {

    NonTransparentProxy proxy;

    function setUp() public override virtual {
        super.setUp();
        proxy = new NonTransparentProxy(ADMIN, address(implementation));
    }

    function test_setImplementation_notAdmin() external {
        vm.startPrank(NOT_ADMIN);
        vm.expectRevert("NTP:SI:NOT_ADMIN");
        proxy.setImplementation(address(1));
    }

}

contract NTPSetImplementatinSuccessTests is NTPTestBase {

    NonTransparentProxy proxy;

    function setUp() public override virtual {
        super.setUp();
        proxy = new NonTransparentProxy(ADMIN, address(implementation));
    }

    function test_setImplementation_notAdmin() external {
        address implementationStorage = address(uint160(uint256(vm.load(address(proxy), IMPLEMENTATION_SLOT))));

        assertEq(implementationStorage, address(implementation));

        vm.startPrank(ADMIN);
        proxy.setImplementation(address(1));

        implementationStorage = address(uint160(uint256(vm.load(address(proxy), IMPLEMENTATION_SLOT))));

        assertEq(implementationStorage, address(1));
    }

}
