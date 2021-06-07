
/*

Description: Get an address for a public key to use when adding/removing validators:
Usage:

npm install
node pubkeyToAddress.js "0xabcd..............................."

*/


const keccak = require('keccak');
const argv = process.argv.slice(2);

function deriveAddress(pubKey) {
    pubkeyBuffer = Buffer.from(pubKey);  
    let keyHash = keccak('keccak256').update(pubkeyBuffer).digest()
    return keyHash.slice(Math.max(keyHash.length - 20, 1))
}

try  {
  pubkey = argv[0].startsWith("0x") ? argv[0] : '0x'+argv[0];
  address = deriveAddress(pubkey);
  console.log(address.toString('hex'));
} catch (error) {
  console.error(error);
}
