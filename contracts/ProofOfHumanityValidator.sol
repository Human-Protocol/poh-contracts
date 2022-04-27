// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * Proof-of-Humanity supports 2 types of proofs:
 * - 101 bytes proof (basic proof, without sender address ownership proof)
 * - 166 bytes proof (sovereign proof, with sender address ownership proof for extended secrurity)
 *
 * Each proof is a hex concatenation of:
 * - 36 or 101 bytes: proof base (see below)
 * - 65 bytes: validator signature (ECDSA_SIG(proof base, validator))
 *
 * 36 bytes proof base (basic proof) is a hex concatenation of:
 * - 32 bytes: random challenge
 * - 4 bytes: timestamp
 *
 * 101 bytes proof base (sovereign proof) is a hex concatenation of:
 * - 32 bytes: random challenge
 * - 65 bytes: address owner signature (ECDSA_SIG(random challenge, address))
 * - 4 bytes: timestamp
 */
abstract contract ProofOfHumanityValidator {
    using ECDSA for bytes32;

    enum ProofOfHumanityValidatorError {
        NoError,
        InvalidLength,
        EmptyValidator
    }

    /**
     * Validates basic proof-of-humanity by checking validator signature.
     * @param proof 101-byte proof-of-humanity
     * @param validator Validator address
     * @return bool True if proof is valid
     */
    function _validateBasicPoH(bytes calldata proof, address validator)
        internal
        pure
        virtual
        returns (bool)
    {
        if (validator == address(0)) {
            _throwError(ProofOfHumanityValidatorError.EmptyValidator);
        }

        (
            bytes32 randomChallenge,
            bytes4 timestamp,
            bytes memory validatorSignature
        ) = _splitBasicPoH(proof);

        address recoveredValidator = keccak256(
            abi.encodePacked(randomChallenge, timestamp)
        ).toEthSignedMessageHash().recover(validatorSignature);

        return validator == recoveredValidator;
    }

    /**
     * Validates sovereign proof-of-hummanity by checking validator signature
     * and message sender signature as well.
     * @param proof 166-byte proof-of-humanity
     * @param validator Validator address
     * @return bool True if proof is valid
     */
    function _validateSovereignPoH(bytes calldata proof, address validator)
        internal
        view
        virtual
        returns (bool)
    {
        if (validator == address(0)) {
            _throwError(ProofOfHumanityValidatorError.EmptyValidator);
        }

        (
            bytes32 randomChallenge,
            bytes memory senderSignature,
            bytes4 timestamp,
            bytes memory validatorSignature
        ) = _splitSovereignPoH(proof);

        address recoveredSender = randomChallenge
            .toEthSignedMessageHash()
            .recover(senderSignature);

        address recoveredValidator = keccak256(
            abi.encodePacked(randomChallenge, senderSignature, timestamp)
        ).toEthSignedMessageHash().recover(validatorSignature);

        return msg.sender == recoveredSender && validator == recoveredValidator;
    }

    /**
     * Splits basic proof-of-humanity to 3 components.
     * @param proof 101-bytes proof-of-humanity
     * @return randomChallenge Random challenge (32 bytes)
     * @return timestamp Timestamp (4 bytes)
     * @return validatorSignature Validator signature (65 bytes)
     */
    function _splitBasicPoH(bytes calldata proof)
        internal
        pure
        virtual
        returns (
            bytes32 randomChallenge,
            bytes4 timestamp,
            bytes memory validatorSignature
        )
    {
        if (proof.length != 101) {
            _throwError(ProofOfHumanityValidatorError.InvalidLength);
        }

        randomChallenge = bytes32(proof[:32]);
        timestamp = bytes4(proof[32:36]);
        validatorSignature = proof[36:101];

        return (randomChallenge, timestamp, validatorSignature);
    }

    /**
     * Splits sovereing proof-of-humanity to 4 components.
     * @param proof 166-bytes proof-of-humanity
     * @return randomChallenge Random challenge (32 bytes)
     * @return senderSignature Transaction sender signature (65 bytes)
     * @return timestamp Timestamp (4 bytes)
     * @return validatorSignature Validator signature (65 bytes)
     */
    function _splitSovereignPoH(bytes calldata proof)
        internal
        pure
        virtual
        returns (
            bytes32 randomChallenge,
            bytes memory senderSignature,
            bytes4 timestamp,
            bytes memory validatorSignature
        )
    {
        if (proof.length != 166) {
            _throwError(ProofOfHumanityValidatorError.InvalidLength);
        }

        randomChallenge = bytes32(proof[:32]);
        senderSignature = proof[32:97];
        timestamp = bytes4(proof[97:101]);
        validatorSignature = proof[101:166];
        return (
            randomChallenge,
            senderSignature,
            timestamp,
            validatorSignature
        );
    }

    function _throwError(ProofOfHumanityValidatorError error) private pure {
        if (error == ProofOfHumanityValidatorError.NoError) {
            return; // no error: do nothing
        } else if (error == ProofOfHumanityValidatorError.InvalidLength) {
            revert("PoH: Invalid proof length");
        } else if (error == ProofOfHumanityValidatorError.EmptyValidator) {
            revert("PoH: Validator is not set");
        }
    }
}
