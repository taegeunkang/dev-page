const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Contents", function () {
  let owner;
  let contents;
  before(async () => {
    owner = await ethers.getSigner();
    const Contents = await ethers.getContractFactory("Contents");
    contents = await Contents.deploy();
    await contents.deployed();
  });
  it("Setting User Infomation Test.", async function () {
    await contents.setUserInfo("mars", "https://pinanta.com/42u382");
    const response = await contents.userInfo(owner.address);
    expect(
      response == [owner.address, "mars", "https://pinanta.com/42u382"],
      "User Info is not the same"
    );
  });
  it("Create Contents Test.", async function () {
    for (let i = 1; i <= 100; i++) {
      await contents.create(
        "하드햇테스트" + String(i),
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"]
      );
    }
    const res = await contents.getContentsOfOwner();

    let b = true;
    for (let j = 0; j < 10; j++) {
      let adr = await contents.contentsBelongsTo(res[j]);
      if (adr != owner.address) {
        b = false;
        break;
      }
    }

    expect(b, "created info doesn't match.");
  });

  it("hashTag test.", async function () {
    const tags = await contents.getTagsOfWriter(owner.address);
    let expectedResponse = [
      ["블록체인", 10],
      ["솔리디티", 10],
    ];
    expect(tags == expectedResponse, "response doesn't match.");
  });

  it("mypage pagination test.", async function () {
    const response = await contents.getContentPageable(0, 20);

    let r = [];
    for (let i = 1; i <= 20; i++) {
      r.push([
        "하드햇테스트" + String(i),
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }
    expect(response == r, "pagination not worked");
  });
  it("mainpage pagination test.", async function () {
    const response = await contents.getContentPageable(0, 20);

    let r = [];
    for (let i = 1; i <= 20; i++) {
      r.push([
        "하드햇테스트" + String(i),
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }
    expect(response == r, "mainpage pagination not worked.");
  });
});
