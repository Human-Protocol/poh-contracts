// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProofOfHumanityValidator.sol";

abstract contract HumanOnly is ProofOfHumanityValidator, Ownable {
    enum HumanOnlyError {
        NoError,
        InvalidProof,
        DiscardedProof
    }

    mapping(bytes32 => bool) private _discardedProofs;

    address private _validator;

    function setHumanityValidator(address validator) public virtual onlyOwner {
        _validator = validator;
    }

    modifier basicPoH(bytes calldata proof) {
        if (!_validateBasicPoH(proof, _validator)) {
            _throwError(HumanOnlyError.InvalidProof);
        }

        bytes32 proofHash = keccak256(proof);
        if (_discardedProofs[proofHash]) {
            _throwError(HumanOnlyError.DiscardedProof);
        }
        _discardedProofs[proofHash] = true;

        _;
    }

    modifier sovereignPoH(bytes calldata proof) {
        if (!_validateSovereignPoH(proof, _validator)) {
            _throwError(HumanOnlyError.InvalidProof);
        }

        bytes32 proofHash = keccak256(proof);
        if (_discardedProofs[proofHash]) {
            _throwError(HumanOnlyError.DiscardedProof);
        }
        _discardedProofs[proofHash] = true;

        _;
    }

    function _throwError(HumanOnlyError error) private pure {
        if (error == HumanOnlyError.NoError) {
            return; // no error: do nothing
        } else if (error == HumanOnlyError.InvalidProof) {
            revert("PoH: Invalid proof-of-humanity");
        } else if (error == HumanOnlyError.DiscardedProof) {
            revert("PoH: Discarded proof-of-humanity");
        }
    }
}
