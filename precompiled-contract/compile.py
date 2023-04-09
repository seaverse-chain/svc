from Poseidon.Blockchain import *

BlockchainUtils.SwitchSolidityVersion("0.8.19")
BlockchainUtils.Compile("WSEA.sol", "WSEA", Optimize=True)
