
/*

Description: Get an address for a public key to use when adding/removing validators:
Usage:

npm install
node pubkeyToAddress.js "0xabcd..............................."

*/


const keccak = require('keccak');
const util = require('ethereumjs-util');
const argv = process.argv.slice(2);

function deriveAddress(pubKey) {
  pubkeyBuffer = Buffer.from(pubKey, 'hex');  
  address = util.pubToAddress(pubkeyBuffer).toString("hex");
  return address
}

try  {
  pubkey = argv[0].startsWith("0x") ? argv[0].substring(2) : argv[0];
  address = deriveAddress(pubkey);
  console.log(address.toString('hex'));
} catch (error) {
  console.error(error);
}
