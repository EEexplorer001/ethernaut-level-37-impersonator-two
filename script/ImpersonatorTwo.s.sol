// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IImpersonatorTwo} from "../src/Interface.sol";

contract ImpersonatorTwoScript is Script {
    address constant instanceAddr = 0xea630140602d3551FBC00E4a6E67f8B95f9c213A;
    address constant ADMIN = 0xADa4aFfe581d1A31d7F75E1c5a3A98b2D4C40f68;

    // Signatures for SWITCH_LOCK with nonce 0
    bytes32 r0 = hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40";
    bytes32 s0 = hex"70026fc30e4e02a15468de57155b080f405bd5b88af05412a9c3217e028537e3";
    uint8 v0 = 27;
    // Signatures for SET_ADMIN with nonce 1
    bytes32 r1 = hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40";
    bytes32 s1 = hex"4c3ac03b268ae1d2aca1201e8a936adf578a8b95a49986d54de87cd0ccb68a79";
    uint8 v1 = 27;
    
    IImpersonatorTwo instance = IImpersonatorTwo(instanceAddr);


    function run() external {
        vm.startBroadcast();
        address player = msg.sender;

        bytes32 z0 = IImpersonatorTwo(instanceAddr).hash_message(string(abi.encodePacked("lock", "0")));
        bytes32 z1 = IImpersonatorTwo(instanceAddr).hash_message(string(abi.encodePacked("admin", "1", ADMIN)));

        bytes32 z2 = IImpersonatorTwo(instanceAddr).hash_message(string(abi.encodePacked("lock", "2")));
        bytes32 z3 = IImpersonatorTwo(instanceAddr).hash_message(string(abi.encodePacked("admin", "3", player)));

        // build FFI command
        string[] memory cmd = new string[](10);
        cmd[0] = "yarn";
        cmd[1] = "ts-node";                              // or your ts runner
        cmd[2] = "./recover_and_sign.ts";
        cmd[3] = vm.toString(r0); // pass r 
        cmd[4] = vm.toString(s0); // s0
        cmd[5] = vm.toString(z0);         // z0
        cmd[6] = vm.toString(s1); // s1
        cmd[7] = vm.toString(z1);         // z1
        cmd[8] = vm.toString(z2);         // z2
        cmd[9] = vm.toString(z3);         // z3

        bytes memory out = vm.ffi(cmd);
        console.log("Signature output:\n", string(out));

        vm.stopBroadcast();
    }
}