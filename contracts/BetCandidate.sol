//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

struct Bet {
    uint amount;
    uint candidate;
    uint timesteamp;
    uint claimed;
}

struct Dispute{
    string candidate1;
    string candidate2;
    string candidate3;
    string image1;
    string image2;
    string image3;
    uint total1;
    uint total2;
    uint total3;
    uint winner;

}

contract BetCandidate{
    
    Dispute public dispute;
    mapping(address => Bet) public allBets;

    address owner;
    uint fee = 1000; //10% (escala de 4 zeros)
    uint public netPrize;


    constructor(){
        owner = msg.sender;
        dispute = Dispute({
            candidate1: "Bruno",
            candidate2: "Ronato",
            candidate3: "Marcos",
            image1: "https://i.ibb.co/Sdw5gkg/Bruno.jpg",
            image2: "https://i.ibb.co/tcJV275/Ronato.jpg",
            image3: "https://i.ibb.co/k3pdhkz/Marcus.jpg",
            total1: 0,
            total2: 0,
            total3: 0,
            winner: 0
        });
    }

    function bet(uint candidate) external payable {
        require(candidate == 1 || candidate == 2 || candidate == 3, "Candidato invalido" );
        require(msg.value > 0, "Valor da aposta invalido");
        require(dispute.winner == 0, "Votacao finalizada");

        Bet memory newBet;
        newBet.amount = msg.value;
        newBet.candidate = candidate;
        newBet.timesteamp = block.timestamp;

        allBets[msg.sender] = newBet;

        if(candidate == 1){
            dispute.total1 += msg.value;
        }else if(candidate == 2){
            dispute.total2 += msg.value;
        }else if(candidate == 3){
            dispute.total3 += msg.value;
        }
    }

    function finish(uint winner) external {
        require(msg.sender == owner, "Conta Invalida");
        require(winner == 1 || winner == 2 || winner == 3, "Candidato invalido" );
        require(dispute.winner == 0, "Votacao ja esta encerrada");

        dispute.winner = winner;

        uint grossPrize = dispute.total1 + dispute.total2 + dispute.total3;
        uint commission = (grossPrize * fee) / 1e4;
        netPrize = grossPrize - commission;

        payable(owner).transfer(commission);

    }

    function claim() external {
        Bet memory userBet = allBets[msg.sender];
        require(dispute.winner > 0, "Votacao em andamento");
        require(userBet.claimed == 0, "Voce ja resgatou seu premio");
        require( dispute.winner == userBet.candidate, "Sau candidato nao ganhou");

        uint winnerAmount;
        if (dispute.winner == 1) {
            winnerAmount = dispute.total1;
        } else if (dispute.winner == 2) {
            winnerAmount = dispute.total2;
        } else {
            winnerAmount = dispute.total3;
        }

        uint ratio = (userBet.amount * 1e4) / winnerAmount;

        uint individualPrize = netPrize * ratio / 1e4;

        allBets[msg.sender].claimed = individualPrize;

        payable(msg.sender).transfer(individualPrize);


    }
}