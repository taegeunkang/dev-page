//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Contents {
    using SafeMath for uint256;

    Content[] public contents; // 메인페이지 전체 조회용
    uint256 private contentsNumber; // 전체 콘텐츠 수

    mapping(address => uint256[]) public contentsOfowner; // 마이페이지 첫화면 전체 스크롤용
    mapping(uint256 => address) public contentsOwnerLoc; // 글의 소유자 확인용
    mapping(address => mapping(string => uint256[])) private contentsOfWriter; //사이드바 숫자 및 조회
    mapping(address => string[]) public tagsOfWriter; // 마이페이지 사이드바 메뉴
    mapping(address => User) public writerInfo; // 사용자 프로필 정보
    mapping(string => bool) private isIn;

    enum Page {
        Main,
        Mypage
    }

    struct Content {
        uint256 idx;
        string title;
        string content;
        address writer;
        string[] tags; // 수정 예정
        uint256 date;
    }

    struct User {
        address adr;
        string nickName;
        string profileImgURL;
    }

    struct Tags {
        string tagName;
        uint256 count;
    }

    function initialize() external {
        contentsNumber = 0;
    }

    // 사용자 프로필 정보 세팅
    function setUserInfo(string memory _nickName, string memory _profileImgURL)
        public
    {
        console.log(msg.sender);
        writerInfo[msg.sender] = User(msg.sender, _nickName, _profileImgURL);
    }

    modifier isContentOwner(uint256 _idx) {
        require(
            contentsOwnerLoc[_idx] == msg.sender,
            "msg.sender doesn't have this"
        );
        _;
    }

    function getTagsOfWriter(address _writer)
        public
        view
        returns (Tags[] memory)
    {
        string[] memory tags = tagsOfWriter[_writer];
        uint256 tagCounts = tags.length;
        Tags[] memory t = new Tags[](tagCounts);

        for (uint256 i = 0; i < tagCounts; i++) {
            uint256 count = contentsOfWriter[_writer][tags[i]].length;
            t[i] = Tags(tags[i], count);
        }
        return t;
    }

    // 게시글 생성
    function create(
        string memory _title,
        string memory _content,
        string[] memory _tags
    ) external {
        contents.push(
            Content(
                contentsNumber,
                _title,
                _content,
                msg.sender,
                _tags,
                block.timestamp
            )
        );
        contentsOfowner[msg.sender].push(contentsNumber);

        for (uint256 i = 0; i < _tags.length; i++) {
            contentsOfWriter[msg.sender][_tags[i]].push(contentsNumber);
            if (!isIn[_tags[i]]) {
                tagsOfWriter[msg.sender].push(_tags[i]);
                isIn[_tags[i]] = true;
            }
        }

        contentsOwnerLoc[contentsNumber] = msg.sender;
        contentsNumber = contentsNumber.add(1);
    }

    // 게시글 수정(내용만 수정 가능)
    function edit(uint256 _idx, string memory _content)
        public
        isContentOwner(_idx)
    {
        contents[_idx].content = _content;
    }

    function getMycontentPageable(uint256 _current, uint256 _amount)
        public
        view
        returns (Content[] memory)
    {
        Content[] memory content = new Content[](_amount);
        uint256[] memory myContents = contentsOfowner[msg.sender];
        uint256 count = 0;

        for (
            uint256 i = _current;
            i < _safePagenation(_current, _amount, Page.Mypage);
            i++
        ) {
            uint256 contentNumber = myContents[i];
            Content memory item = contents[contentNumber];
            content[count] = item;
            count = count.add(1);
        }

        return content;
    }

    //페이지네이션
    function getContentPageable(uint256 _current, uint256 _amount)
        public
        view
        returns (Content[] memory)
    {
        Content[] memory content = new Content[](_amount);
        uint256 count = 0;

        for (
            uint256 i = _current;
            i < _safePagenation(_current, _amount, Page.Main);
            i++
        ) {
            content[count] = contents[i];
            count = count.add(1);
        }

        return content;
    }

    // 마지막 페이지 핸들링
    function _safePagenation(
        uint256 _cursor,
        uint256 _val,
        Page loc
    ) private view returns (uint256) {
        uint256 size = (loc == Page.Main)
            ? contentsNumber
            : contentsOfowner[msg.sender].length;

        if (_cursor + _val >= size) {
            return size;
        }

        return _cursor + _val;
    }
}
