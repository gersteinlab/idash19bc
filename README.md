# idash19bc
Solution to iDASH'19 challenge track 1


****************************************************************************************
****************************************************************************************
INSTRUCTIONS TO RUN GeneDrugRepo SMART CONTRACTS IN TRUFFLE
****************************************************************************************
****************************************************************************************


****************************************************************************************
Part 1: Configuring Truffle Directories
****************************************************************************************

1. Install Truffle via the following terminal command:

	npm install -g truffle

2. Make a directory named "truffle" and navigate to it. 

3. Initialize Truffle via the following terminal command:
	
	truffle init

4. This will create four sub-directories and a config file: /build, /contracts, /migrations, /test, and truffle-config.js. 

5. Move the smart contract solidity files to the /contracts dir. 

6. Create a file in the /migrations dir named 2_deploy_contracts.js with the following contents:
	
	var GDR = artifacts.require("./GeneDrugRepo.sol");
	module.exports = function(deployer) {
   		deployer.deploy(GDR);
	};

7. Move the gdr_train javascript test files to /test.


****************************************************************************************
Part 2: Running Contracts in Truffle Test Network
****************************************************************************************

1. Open terminal, cd to truffle dir, run the following command:
	
	truffle develop

2. Open a second terminal window. Run the test files to observe contract behavior via the following command:

	truffle test ./test/[name of javascript test file]

3. Alternatively, to deploy contracts to a truffle test network and call transactions, see the instructions on the Truffle documentation: site:  https://www.trufflesuite.com/docs/truffle/getting-started/running-migrations
