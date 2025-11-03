// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IImpersonatorTwo} from "../src/Interface.sol";

contract Solution is Script {
    address constant instanceAddr = 0xea630140602d3551FBC00E4a6E67f8B95f9c213A;
    IImpersonatorTwo instance = IImpersonatorTwo(instanceAddr);
    bytes sig2 = hex"84fe83b973cb36a59d8a0c7dde2d6a34e9e04a2c5b3d3a9470ea2ff338326f9a0fe56abd691abe411f69fbd82ca10fcdb13db04dc428b944f2de1bb8c801a6671b";
    bytes sig3 = hex"64ed58ff0fa4a85cbcf188cdaa13c05fb8f01a6e2ef9c278ca9025364a1d5e022f1b372cac547b6b64ddc03c0eeaf5bcecab249a129ef63a017eeac47e7b7c971b";

    function run() external {
        vm.startBroadcast();

        instance.switchLock(sig2);
        instance.setAdmin(sig3, msg.sender);
        instance.withdraw();

        console.log("New admin:", instance.admin());
        console.log("Contract balance:", address(instance).balance);

        vm.stopBroadcast();
    }
}