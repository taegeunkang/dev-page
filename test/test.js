const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Contents", function () {
    let owner;
    before(async () => {
        owner = await ethers.getSigner();
    })
    it("Setting User Infomation Test.", async function () {
        const Contents = await ethers.getContractFactory("Contents");
        const contents = await Contents.deploy();
        await contents.deployed();

        await contents.setUserInfo("mars", "https://pinanta.com/42u382");
        const response = await contents.writerInfo(owner.address);
        expect(response == [owner.address, "mars", "https://pinanta.com/42u382"], "User Info is not the same");

    });
    it("Create Contents Test.", async function () {
        const Contents = await ethers.getContractFactory("Contents");
        const contents = await Contents.deploy();
        await contents.deployed();

        await contents.create("하드햇 테스트", "오늘은 하드햇 컨텐츠를 테스트해보겠습니다."
            , ["솔리디티", "블록체인"]);

        await contents.create("하드햇 테스트1", "컴투스 홀딩스 가즈아아아아아"
            , ["블록체인"]);

        await contents.create("하드햇 테스트2", "컴투스 홀딩스 제발 합격!!"
            , ["블록체인"]);

        // console.log(await contents.contents(0));
        // console.log(await contents.contents(1));
        // console.log(await contents.getTagsOfWriter(owner.address));
        expect(await contents.contentsOwnerLoc(0) == owner.address, "주소 불일치");


    })
});
