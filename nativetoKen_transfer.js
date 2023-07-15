const { Console } = require('console');
const { Web3 } = require('web3')
const web3 = new Web3('https://matic-mumbai.chainstacklabs.com');
const senderAddress = '0xdde3A0846d3AA43588eef9FCe2e60c2353370d1c';
const receiverAddress = '0xe15e6103410392ba04a0f8b0fcd2c721ea1b3a0a';
const privateKey = "";
const deploy = async () => {
  
    const createTransaction = await web3.eth.accounts.signTransaction(
       {
          from: senderAddress,
          to: receiverAddress,
           gasPrice: web3.eth.gasPrice,
            maxPriorityFeePerGas: "250000000000",
             maxFeePerGas: "250000000000",
          gas: '500000',
          value:"1000000000000000000"
       },
       privateKey // private key variable
    );
    const createReceipt = await web3.eth.sendSignedTransaction(
        createTransaction.rawTransaction
     );
    console.log(
       `Transaction successful with hash: ${createReceipt.transactionHash}`// for transaction hash in rinkeby
    );
};

deploy()
