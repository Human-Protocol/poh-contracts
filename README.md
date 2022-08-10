# Solidity contracts for verifying proof-of-humanity on-chain

[![NPM](https://img.shields.io/npm/v/poh-contracts)](https://www.npmjs.com/package/poh-contracts)

Set of convenient utilities for verifying proof-of-humanity on-chain within Solidity smart contracts.

Proof-of-Humanity is signed proof that the transaction sender is a human rather than a bot. We are trusting the proof signer (validator) that they did use some method to prove sender humanity off-chain. That could be a CAPTCHA, biometric verification, and so on. Now we can check the validity and uniqueness of this proof on-chain before processing the transaction.

See also:

[Proof-of-HUMANity on-chain: protect your smart contracts from bots](https://www.humanprotocol.org/blog/proof-of-humanity-on-chain-protect-your-smart-contracts-from-bots)

[Proof-of-Humanity hCaptcha Validator API](https://github.com/Human-Protocol/poh-validator-hcaptcha-api)

## HumanOnly

This is a basic abstract contract you should inherit from. It exposes the following API:

### Methods

`setHumanityValidator(<address>)` – sets the address of the humanity validator you trust. Usually, this is the address of the account used to sign proof-of-humanity in the backend server you are in control or trust. Here is an [example server](https://github.com/Human-Protocol/poh-validator-hcaptcha-api) for hCaptcha.

> Validator could be set either in contract `constructor`, or later, by the contract owner.

### Modifiers

`basicPoH(<proof>)` – ensures that the `basic` proof is valid and never seen before.

`sovereignPoH(<proof>)` – ensures that the `sovereign` proof is valid and never seen before.

If the proof is invalid, transaction is rejected.

> `proof` must be provided as a parameter for a modified method ([example](https://github.com/Human-Protocol/poh-contracts#4-protect-your-methods-by-adding-the-proof-parameter-and-one-of-the-poh-modifiers)).

## Proof-of-Humanity types

Two types of proof-of-humanity are supported: `basic` and `sovereign`.

### Basic proof

The basic proof is 101 bytes long. It is a random challenge and a timestamp signed by a trusted validator.

```
random challenge | timestamp | validator signature
32 bytes         | 4 bytes   | 65 bytes
```

### Sovereign proof

Sovereign proof includes the signature of the transaction sender over the random challenge. This is useful if you want the proof to be tightened to the sender's address. The sovereign proof is 166 bytes long.

```
random challenge | sender signature | timestamp | validator signature
32 bytes         | 65 bytes         | 4 bytes   | 65 bytes
```

## Install

```
npm install poh-contracts
```

## Usage

### 1. Import `HumanOnly.sol` contract

```
`import "poh-contracts/Human-Protocol/HumanOnly.sol";`
```

### 2. Inherit your contract from `HumanOnly`

```
contract MyContract is HumanOnly
```

### 3. Ensure the validator address is set

```
constructor() {
  setHumanityValidator(0x...);
}
```

> This is the address used to sign proofs on a backend server you trust.

### 4. Protect your methods by adding the `proof` parameter and one of the PoH modifiers

```
function doSomethingImpotant(bytes calldata proof) public basicPoH(proof)
```

> Ensure to provide a valid `proof` when calling this function from your dApp.

## See also

- [Proof-of-HUMANity on-chain: protect your smart contracts from bots](https://www.humanprotocol.org/blog/proof-of-humanity-on-chain-protect-your-smart-contracts-from-bots)
- [Proof-of-Humanity-React](https://npmjs.com/package/poh-react)
- [Proof-of-Humanity hCaptcha Validator React](https://npmjs.com/package/poh-validator-hcaptcha-react)
- [Proof-of-Humanity hCaptcha Validator API](https://hub.docker.com/r/bakoushin/poh-validator-hcaptcha)
- [Counter dApp Example](https://github.com/Human-Protocol/poh-counter-example)

## Author

Alex Bakoushin

## License

MIT
