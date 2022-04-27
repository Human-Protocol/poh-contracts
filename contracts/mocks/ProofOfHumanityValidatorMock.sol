// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import "../ProofOfHumanityValidator.sol";

contract ProofOfHumanityValidatorMock is ProofOfHumanityValidator {
    function validateBasicPoH(bytes calldata proof, address validator)
        public
        pure
        returns (bool)
    {
        return _validateBasicPoH(proof, validator);
    }

    function validateSovereignPoH(bytes calldata proof, address validator)
        public
        view
        returns (bool)
    {
        return _validateSovereignPoH(proof, validator);
    }

    function splitBasicPoH(bytes calldata proof)
        public
        pure
        returns (
            bytes32 randomChallenge,
            bytes4 timestamp,
            bytes memory validatorSignature
        )
    {
        return _splitBasicPoH(proof);
    }

    function splitSovereignPoH(bytes calldata proof)
        public
        pure
        returns (
            bytes32 randomChallenge,
            bytes memory senderSignature,
            bytes4 timestamp,
            bytes memory validatorSignature
        )
    {
        return _splitSovereignPoH(proof);
    }
}
