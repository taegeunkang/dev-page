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
    await contents.setUserInformation("mars", "https://pinanta.com/42u382");
    const response = await contents.userInformation(owner.address);
    const expected = [owner.address, "mars", "https://pinanta.com/42u382"];
    expect(JSON.stringify(response)).to.equal(JSON.stringify(expected));
  });

  it("User Information Doesn't Exist Test.", async function () {
    const users = await ethers.getSigners();
    const user01 = users[1];
    const userInformation = await contents.userInformation(user01.address);
    expect(userInformation[0]).to.equal("0x0000000000000000000000000000000000000000");
  });
  it("Create Content Test.", async function () {
    for (let i = 1; i <= 100; i++) {
      await contents.create(
        "하드햇테스트" + String(i),
        "https://localhost:3000/img",
        "테스트" + String(i),
        String(new Date()),
        ["블록체인", "솔리디티"]
      );
    }
    const res = await contents.getContentOwner(owner.address);
    let b = true;
    for (let j = 0; j < 10; j++) {
      let adr = await contents.contentWriter(res[j]);
      if (adr != owner.address) {
        b = false;
        break;
      }
    }

    expect(b).to.equal(true);
  });

  it("Tag Test.", async function () {
    const tags = await contents.getUserSTag(owner.address);
    let expectedResponse = [
      ["블록체인", BigNumber.from(100)],
      ["솔리디티", BigNumber.from(100)],
    ];

    expect(JSON.stringify(tags)).to.equal(JSON.stringify(expectedResponse));
  });

  it("UserContent Pagination Test.", async function () {
    let total_count = await contents.getContentOwner(owner.address);

    total_count = total_count.length;
 
    const response = await contents.getUserContentPagination(
      total_count,
      20,
      owner.address
    );

    const writer = await contents.userInformation(owner.address);
    let r = [];
    for (let i = total_count - 1; i >= total_count - 20; i--) {
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
  it("Mainpage Pagination Test.", async function () {
    const total_count = await contents.totalContentNumber();

    const response = await contents.getContentPagination(total_count, 20);

    let r = [];
    for (let i = total_count - 1; i >= total_count - 20; i--) {
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

  it("TagContent Paginantion Test.", async function () {
    const tags = await contents.getUserSTag(owner.address);
    let response_count = [];
    for(let i =0; i < tags.length; i++ ){
     
      const response = await contents.getTagContentPagination(owner.address, tags[i].tagName, tags[i].count, 20);
      response_count.push(response.length);
    }
    expect(JSON.stringify(response_count)).to.equal(JSON.stringify([20, 20]));
    

  });

  it("Mainpage SafePagination Test.", async function () {
    let total_count = await contents.totalContentNumber();
    const amount = 120
    total_count = parseInt(total_count);
    
    const response = await contents.getContentPagination(
      total_count,
      amount
    );


    let r = [];
    for (let i = total_count - 1; i >= 0; i--) {
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
  it("UserContent SafePagination Test.", async function () {
    let total_count = await contents.getContentOwner(owner.address);
    total_count = total_count.length;

    const response = await contents.getUserContentPagination(
      total_count,
      total_count + 10,
      owner.address
    );
    let r = [];
    for (let i = total_count - 1; i >= 0; i--) {
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

  it("TagContent SafePaginantion Test.", async function () {
    const tags = await contents.getUserSTag(owner.address);
    let response_count = [];
    for(let i =0; i < tags.length; i++ ){
     
      const response = await contents.getTagContentPagination(owner.address, tags[i].tagName, tags[i].count, tags[i].count+ 20);
      response_count.push(response.length);
    }
    expect(JSON.stringify(response_count)).to.equal(JSON.stringify([100, 100]));
    

  });
});
