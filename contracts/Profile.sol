//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Profile {
    struct Info{
        string prifleURL;
        string nickName;
    }
    
    mapping(address => Info) public profiles;

    function setProfile(string memory _profileURL, string memory _nickName) public {
        profiles[msg.sender] = Info(_profileURL, _nickName);
    }

}