// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { Address, TestUtils } from "../modules/contract-test-utils/contracts/test.sol";

import { NonTransparentProxied } from "../contracts/NonTransparentProxied.sol";
import { NonTransparentProxy }   from "../contracts/NonTransparentProxy.sol";

contract NTPTestBase is TestUtils {

    bytes32 internal constant ADMIN_SLOT          = bytes32(uint256(keccak256("eip1967.proxy.admin"))          - 1);
    bytes32 internal constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    address internal ADMIN     = address(new Address());
    address internal NOT_ADMIN = address(new Address());

    NonTransparentProxied internal implementation;

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

    NonTransparentProxy internal proxy;

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

contract NTPSetImplementationSuccessTests is NTPTestBase {

    NonTransparentProxied internal newImplementation;
    NonTransparentProxied internal proxied;
    NonTransparentProxy   internal proxy;

    function setUp() public override virtual {
        super.setUp();

        newImplementation = new NonTransparentProxied();
        proxy             = new NonTransparentProxy(ADMIN, address(implementation));
        proxied           = NonTransparentProxied(address(proxy));
    }

    function test_setImplementation() external {
        address implementationStorage = address(uint160(uint256(vm.load(address(proxy), IMPLEMENTATION_SLOT))));

        assertEq(implementationStorage,    address(implementation));
        assertEq(proxied.implementation(), address(implementation));

        vm.startPrank(ADMIN);
        proxy.setImplementation(address(newImplementation));

        implementationStorage = address(uint160(uint256(vm.load(address(proxy), IMPLEMENTATION_SLOT))));

        assertEq(implementationStorage,    address(newImplementation));
        assertEq(proxied.implementation(), address(newImplementation));
    }

}
