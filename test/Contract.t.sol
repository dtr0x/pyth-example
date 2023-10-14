// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../lib/pyth/IPyth.sol";
import {Surl} from "../lib/Surl.sol";
import "../lib/openzeppelin-utils/Strings.sol";
import "../lib/Base64.sol";

contract Contract is Test {

    using Surl for *;

    IPyth pyth = IPyth(0x4305FB66699C3B2702D4d05CF36551390A4c69C6);

    bytes32 ethFeed = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;

    function testUpdateAndGetPrice() public {
        updateEthPrice();
        PythStructs.Price memory price = pyth.getPrice(ethFeed);
        console.log("Price:");
        console.logInt(price.price);
        console.log("\nExponent:");
        console.logInt(price.expo);
        console.log("\nPublish Time:");
        console.log(price.publishTime);
    }

    function updateEthPrice() private {
        string[] memory headers = new string[](1);
        headers[0] = "accept: application/json";
        string memory url = "https://hermes.pyth.network/api/get_vaa?id=";
        url = string.concat(
            url, 
            "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace&publish_time=");
        url = string.concat(url, Strings.toString(block.timestamp - 60));
        (uint256 status, bytes memory data) = url.get(headers);
        if (status != 200) revert("Bad request");

        // this is the index of the first " enclosing the base64 VAA string
        uint256 firstIndex = 8;

        uint256 lastIndex;
        // find the last index by getting the next " (0x22 in hex)
        for (uint256 i = firstIndex + 1; lastIndex == 0; ++i) {
            if (data[i] == bytes1(0x22)) {
                lastIndex = i;
            }
        }

        // put the VAA in a new bytes array
        bytes memory priceUpdateBytes;
        for (uint256 i = firstIndex; i < lastIndex; ++i) {
            priceUpdateBytes = bytes.concat(priceUpdateBytes, data[i]);
        }

        bytes[] memory priceUpdateData = new bytes[](1);

        // priceUpdateBytes in base64, decode to binary
        priceUpdateData[0] = Base64.decode(string(priceUpdateBytes));

        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);
    }

}

