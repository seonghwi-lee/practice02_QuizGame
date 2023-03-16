// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz {
    struct Quiz_item {
        uint id;
        string question;
        string answer;
        uint min_bet;
        uint max_bet;
    }

    mapping(address => uint256)[] public bets;
    mapping(address => uint256) public bet;
    uint public vault_balance;
    address public owner;
    uint public quiz_num;
    mapping(uint256 => Quiz_item) public quizs;
    mapping(address => uint256) solved;

    constructor() {
        Quiz_item memory q;
        owner = msg.sender;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);
        quizs[q.id] = q;
        ++quiz_num;
    }

    function getAnswer(uint quizId) public view returns (string memory) {
        require(msg.sender == owner);
        return quizs[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory quiz = quizs[quizId];
        quiz.answer = "";
        return quiz;
    }

    function getQuizNum() public view returns (uint) {
        return quiz_num;
    }

    function betToPlay(uint256 quizId) public payable {
        require(msg.value <= quizs[quizId].max_bet, "exceeds maximam");
        require(msg.value >= quizs[quizId].min_bet, "need more bet");
        bets.push();
        bets[quizId - 1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        bool chk = keccak256(abi.encodePacked(quizs[quizId].answer)) ==
            keccak256(abi.encodePacked(ans));
        if (chk) {
            solved[msg.sender] += bets[quizId - 1][msg.sender] * 2;
        } else {
            vault_balance += bets[quizId - 1][msg.sender];
            bets[quizId - 1][msg.sender] = 0;
        }
        return chk;
    }

    function claim() public {
        uint256 amount = solved[msg.sender];
        solved[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    receive() external payable {}
}
