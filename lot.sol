
//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;


  
contract Lottery {
    
    //list of players registered in lotery
    address payable[] public players;
    address public admin;
    
    
    
    constructor() {
        admin = msg.sender;
        //automatically adds admin on deployment
        players.push(payable(admin));
    }
    
    modifier onlyOwner() {
        require(admin == msg.sender, "You are not the owner");
        _;
    }
    
    
    
    receive() external payable {
        //require that the transaction value to the contract is 0.1 ether
        require(msg.value == 1 ether , "Must send 0.1 ether amount");
        
        //makes sure that the admin can not participate in lottery
        require(msg.sender != admin);
        
        // pushing the account conducting the transaction onto the players array as a payable adress
        players.push(payable(msg.sender));
    }
    
    
    function getBalance() public view onlyOwner returns(uint){
        // returns the contract balance 
        return address(this).balance;
    }
    
     
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    

    function amor() public onlyOwner{
        require(players.length >= 3 , "Not enough players in the lottery");

        address payable a;

         a = players[random() % players.length];
         a.transfer((getBalance()/ players.length));
         payable(admin).transfer( (getBalance() * 10) / 100);

    }
     
    function pickWinner() public onlyOwner {

        //makes sure that we have enough players in the lottery  
        require(players.length >= 3 , "Not enough players in the lottery");
        
        address payable winner;
        
        //selects the winner with random number
        winner = players[random() % players.length];
        
        //transfers balance to winner
        winner.transfer( (getBalance() * 90) / 100); //gets only 90% of funds in contract
        payable(admin).transfer( (getBalance() * 10) / 100); //gets remaining amount AKA 10% -> must make admin a payable account
        
        
        //resets the plays array once someone is picked
       resetLottery(); 
        
    }

    
     
    function resetLottery() internal {
        players = new address payable[](0);
    }

}
