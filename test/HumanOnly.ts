import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("HumanOnly", async function () {
  let humanOnlyMock: Contract;
  let validBasicProof: string;
  let invalidBasicProof: string;
  let validSovereignProof: string;
  let invalidSovereignProof: string;

  before(async function () {
    const [sender, validator, someone] = await ethers.getSigners();

    const randomChallenge =
      "0xef9990adc264ccc6e55bd0cfbf8dbef5177760273ee5aa3f65aae4bbb014750f";

    const timestamp = "0x623d0600"; // 2022-03-25 00:00:00Z

    validBasicProof = await generateBasicProof(
      randomChallenge,
      timestamp,
      validator
    );
    invalidBasicProof = await generateBasicProof(
      randomChallenge,
      timestamp,
      someone /* not valid validator */
    );

    validSovereignProof = await generateSovereignProof(
      randomChallenge,
      timestamp,
      sender,
      validator
    );
    invalidSovereignProof = await generateSovereignProof(
      randomChallenge,
      timestamp,
      sender,
      someone /* not valid validator */
    );
  });

  beforeEach(async function () {
    const HumanOnlyMock = await ethers.getContractFactory("HumanOnlyMock");
    humanOnlyMock = await HumanOnlyMock.deploy();
    await humanOnlyMock.deployed();
  });

  it("Should not revert when provided a valid basic PoH", async function () {
    const actionCall = await humanOnlyMock.testBasicPoH(validBasicProof);
    await expect(actionCall).to.emit(humanOnlyMock, "Success");
  });

  it("Should not revert when provided a valid sovereign PoH", async function () {
    const actionCall = await humanOnlyMock.testSovereignPoH(
      validSovereignProof
    );
    await expect(actionCall).to.emit(humanOnlyMock, "Success");
  });

  it("Should successfully revert when provided invalid basic PoH (invalid validator)", async function () {
    const actionCall = humanOnlyMock.testBasicPoH(invalidBasicProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Invalid proof-of-humanity"
    );
  });

  it("Should successfully revert when provided invalid sovereign PoH (invalid validator)", async function () {
    const actionCall = humanOnlyMock.testSovereignPoH(invalidSovereignProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Invalid proof-of-humanity"
    );
  });

  it("Should successfully revert when provided unseen invalid basic PoH (invalid validator)", async function () {
    const actionCall = humanOnlyMock.testBasicPoH(invalidBasicProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Invalid proof-of-humanity"
    );
  });

  it("Should successfully revert when provided unseen invalid sovereign PoH (invalid validator)", async function () {
    const actionCall = humanOnlyMock.testSovereignPoH(invalidSovereignProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Invalid proof-of-humanity"
    );
  });

  it("Should successfully revert when provided discarded basic PoH (already seen)", async function () {
    await humanOnlyMock.testBasicPoH(validBasicProof);
    const actionCall = humanOnlyMock.testBasicPoH(validBasicProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Discarded proof-of-humanity"
    );
  });

  it("Should successfully revert when provided discarded sovereign PoH (already seen)", async function () {
    await humanOnlyMock.testSovereignPoH(validSovereignProof);
    const actionCall = humanOnlyMock.testSovereignPoH(validSovereignProof);
    await expect(actionCall).to.be.revertedWith(
      "PoH: Discarded proof-of-humanity"
    );
  });

  it("Should set an empty validator and revert any proofs afterwards", async function () {
    const emptyAddress = ethers.utils.getAddress(
      "0x0000000000000000000000000000000000000000"
    );

    await humanOnlyMock.setHumanityValidator(emptyAddress);

    const actionCall = humanOnlyMock.testBasicPoH(validBasicProof);
    await expect(actionCall).to.be.revertedWith("PoH: Validator is not set");
  });

  it("Should reset a validator and not revert afterwards", async function () {
    const emptyAddress = ethers.utils.getAddress(
      "0x0000000000000000000000000000000000000000"
    );

    const validatorAddress = (await ethers.getSigners())[1].address;

    await humanOnlyMock.setHumanityValidator(emptyAddress);
    await humanOnlyMock.setHumanityValidator(validatorAddress);

    const actionCall = await humanOnlyMock.testBasicPoH(validBasicProof);
    await expect(actionCall).to.emit(humanOnlyMock, "Success");
  });
});

async function generateBasicProof(
  randomChallenge: string,
  timestamp: string,
  validator: SignerWithAddress
) {
  const hash = ethers.utils.keccak256(
    ethers.utils.hexConcat([randomChallenge, timestamp])
  );
  const validatorSignature = await validator.signMessage(
    ethers.utils.arrayify(hash)
  );
  const proof = ethers.utils.hexConcat([
    randomChallenge,
    timestamp,
    validatorSignature,
  ]);
  return proof;
}

async function generateSovereignProof(
  randomChallenge: string,
  timestamp: string,
  sender: SignerWithAddress,
  validator: SignerWithAddress
) {
  const senderSignature = await sender.signMessage(
    ethers.utils.arrayify(randomChallenge)
  );
  const hash = ethers.utils.keccak256(
    ethers.utils.hexConcat([randomChallenge, senderSignature, timestamp])
  );
  const validatorSignature = await validator.signMessage(
    ethers.utils.arrayify(hash)
  );
  const proof = ethers.utils.hexConcat([
    randomChallenge,
    senderSignature,
    timestamp,
    validatorSignature,
  ]);
  return proof;
}
