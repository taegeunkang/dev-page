const { EtherscanProvider } = require("@ethersproject/providers");
const { expect } = require("chai");
const { BigNumber } = require("ethers");
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
  it("User Infomation Exists Test.", async function () {
    await contents.setUserInfo("mars", "https://pinanta.com/42u382");
    const response = await contents.userInfo(owner.address);
    const expected = [owner.address, "mars", "https://pinanta.com/42u382"];
    expect(JSON.stringify(response)).to.equal(JSON.stringify(expected));
  });

  it("User Information Doesn't exist Test.", async function () {
    const users = await ethers.getSigners();
    const user01 = users[1];
    const userInfo = await contents.userInfo(user01.address);
    expect(userInfo[0]).to.equal("0x0000000000000000000000000000000000000000");
  });
  it("Create Contents Test.", async function () {
    for (let i = 1; i <= 100; i++) {
      await contents.create(
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"]
      );
    }
    const res = await contents.getContentsOfOwner(owner.address);

    let b = true;
    for (let j = 0; j < 10; j++) {
      let adr = await contents.contentsBelongsTo(res[j]);
      if (adr != owner.address) {
        b = false;
        break;
      }
    }

    expect(b).to.equal(true);
  });

  it("hashTag test.", async function () {
    const tags = await contents.getTagsOfWriter(owner.address);
    let expectedResponse = [
      ["블록체인", BigNumber.from(100)],
      ["솔리디티", BigNumber.from(100)],
    ];

    expect(JSON.stringify(tags)).to.equal(JSON.stringify(expectedResponse));
  });

  it("mypage pagination test.", async function () {
    const total_count = await contents.getContentsOfOwner(owner.address).length;
    const response = await contents.getMycontentPageable(
      total_count,
      20,
      owner.address
    );
    console.log(response);
    const writer = await contents.userInfo(owner.address);
    let r = [];
    for (let i = total_count; i >= total_count - 20; i--) {
      r.push([
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        writer,
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }
    expect(response.length).to.equal(r.length);
  });
  it("mainpage pagination test.", async function () {
    const total_count = await contents.contentsNumber();

    const response = await contents.getContentPageable(total_count, 20);

    let r = [];
    for (let i = total_count; i >= total_count - 20; i--) {
      r.push([
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }
    expect(response.length).to.equal(r.length);
  });

  it("mainpage safePagination test.", async function () {
    const total_count = await contents.contentsNumber();
    const response = await contents.getContentPageable(
      total_count,
      total_count + 10
    );
    let r = [];
    for (let i = total_count; i >= 0; i--) {
      r.push([
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }

    const contents_size = response.length;
    const dummy_size = r.length;

    expect(contents_size).to.equal(dummy_size);
  });
  it("mypage safePagination test.", async function () {
    const total_count = await contents.getContentsOfOwner(owner.address).length;
    const response = await contents.getMycontentPageable(
      total_count,
      total_count + 10,
      owner.address
    );
    let r = [];
    for (let i = total_count; i >= 0; i--) {
      r.push([
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"],
      ]);
    }

    const contents_size = response.length;
    const dummy_size = r.length;

    expect(contents_size).to.equal(dummy_size);
  });
});
