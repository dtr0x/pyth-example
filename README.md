## Pyth Example
An example of how to interact with the Pyth contract on Ethereum mainnet using Foundry. The test will update and retrieve the price of ETH in a forked environment, using [surl](https://github.com/memester-xyz/surl) to make HTTP requests.

### Usage 
```
forge test -f $NODE_URL -vv
```
Replace `$NODE_URL` with your RPC endpoint.

Example output:
```
[PASS] testUpdateAndGetPrice() (gas: 8149821)
Logs:
  Price:
  154382015731
  
Exponent:
  -8
  
Publish Time:
  1697230271
```

See the [test contract](./test/Contract.t.sol) for more information.

