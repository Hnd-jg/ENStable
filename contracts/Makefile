-include .env

.PHONY: build test clean anvil deploy-unichain

# Compilation and Build
build:
	forge build

# Local Testing (Anvil)
test-local:
	forge test --fork-url http://127.0.0.1:8545 -vvv

# Integration Testing (Unichain Fork)
test-fork:
	forge test --fork-url $(UNICHAIN_SEPOLIA_RPC_URL) -vvv

# Coverage Analysis
coverage:
	forge coverage --report debug > coverage.txt

# Secure Deployment (Interactive Wallet)
# Utilizing the pre-decrypted 'agent-mockup-hackaton' keystore account
deploy-unichain:
	forge script script/DeployIdentityVault.s.sol \
	--rpc-url $(UNICHAIN_SEPOLIA_RPC_URL) \
	--account agent-mockup-hackaton \
	--sender 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
	--broadcast \
	-vvvv
