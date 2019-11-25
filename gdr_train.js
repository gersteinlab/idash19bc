var GDR = artifacts.require("./GeneDrugRepo.sol");

contract("GDR", function(accounts) {
  	var gene_drug_repo;

//**********************************************************************************************
// insertObservation()from Training_Data_1.txt. 
//**********************************************************************************************
const iused = 0
//var igas = 0
it("it inserts observation from Training_Data_1", function() {
  return GDR.deployed().then(function(instance) {
    var fs = require("fs");
    var text = fs.readFileSync("/Users/charlottebrannon/Desktop/new_truffle/contracts/Training_Data_2_Head.txt").toString('utf-8');
    var textByLine = text.split("\n");
    var arrayLength = textByLine.length;
    //console.log("CONTRACT CONTAINS".concat(" ", arrayLength.toString(10), " ", "ENTRIES"));
    for (var i = 0; i < arrayLength; i++) {
        var fields = textByLine[i].split("\t");
        //console.log(fields[1]);
        //console.log("inserted:".concat( "[ ", fields[0], " ", fields[1], " ", fields[2], " ", fields[3], " ", fields[4], " ", fields[5], " ]"));
        //instance.insertObservation(fields[0], fields[1], fields[2], fields[3], (String(fields[4]) == "true"), (String(fields[5]) == "true"));
        const igas = instance.insertObservation.estimateGas(fields[0], fields[1], fields[2], fields[3], (String(fields[4]) == "true"), (String(fields[5]) == "true"));
        console.log(Number(igas));
    }
    return instance;
  }).then(function() {
        
        const iused = process.memoryUsage().heapUsed / 1024 / 1024;
        console.log(`insert uses approximately ${Math.round(iused * 100) / 100} MB`);
            
      });
});

const qgas = 0
it("it tests the main query function", function() {
  return GDR.deployed().then(function(instance) {
  gene_drug_repo = instance;
  return gene_drug_repo.query.call("CALU", "44", "duloxetine"); // ("CALU", "*", "*") "FDPS", "11", "midazolam" CALU  44  duloxetine

  }).then(function(structArray) {
        console.log(structArray);
        console.log("Should be the struct for [CALU  44  duloxetine]");
        const qused = (process.memoryUsage().heapUsed / 1024 / 1024) - iused;
        console.log(`query uses approximately ${Math.round(qused * 100) / 100} MB`);
    });
});});