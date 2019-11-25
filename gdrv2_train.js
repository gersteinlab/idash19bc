var GDR = artifacts.require("./GeneDrugRepoV2.sol");
const disk = require('diskusage');
const os = require('os');
let path = os.platform() === 'win32' ? 'c:' : '/';
const {
  performance
} = require('perf_hooks');

contract("GDR", function(accounts) {
  	var gene_drug_repo;

const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}
//**********************************************************************************************
// insertObservation()from Training_Data_1.txt. 
//**********************************************************************************************
const fs = require("fs");
const text = fs.readFileSync("/Users/charlottebrannon/Desktop/Training_Data_various/Training_Data_5000.txt").toString('utf-8');
const textByLine = text.split("\n");
const arrayLength = textByLine.length;
//const iused = 0
it("it inserts observation from Training_Data_1", async() => {
  
  disk.check(path)
  .then(info => console.log(`pre-insertion: ${info.free}`))
  .catch(err => console.error(err))

  let meta = await GDR.deployed();

    //console.log("CONTRACT CONTAINS".concat(" ", arrayLength.toString(10), " ", "ENTRIES"));
  for (let i = 0; i < arrayLength; i++) {
    fields = textByLine[i].split("\t");
    //console.time("insert test");
    let result = await meta.insertObservation(fields[0], fields[1], fields[2], fields[3], (String(fields[4]) == "true"), (String(fields[5]) == "true"));
    //console.timeEnd("insert test")
    if (i % 100 == 0) {
      await sleep(1000); // "inserting 200 entries at a time"
    }
    //await sleep(1000); // "inserting 1 entry at a time"   
    }
    
  //const iused = process.memoryUsage().heapUsed / 1024 / 1024;
  //console.log(`insert uses approximately ${Math.round(iused * 100) / 100} MB`);
  disk.check(path)
  .then(info => console.log(`post-insertion: ${info.free}`))
  .catch(err => console.error(err))
  
  });

/*
    it("it tests the main query function: (* * *)", function() {
      return GDR.deployed().then(function(instance) {
      gene_drug_repo = instance;
      instance.query.call("*", "*", "*");
      }).then(function(structArray) {
          console.log(structArray);
          console.log("Should be the struct for [CALU, 91, gemcitabine]");
      });
  });
*/



//const fs = require("fs");
//const text = fs.readFileSync("/Users/charlottebrannon/Desktop/new_truffle/contracts/Training_Data_1_Head.txt").toString('utf-8');
//const textByLine = text.split("\n");
const numSearches = 100;
//const qused = 0

it("it tests the main query function: (gene var *)", async() => {
    //disk.check(path)
    //.then(info => console.log(`pre-query: ${info.free}`))
    //.catch(err => console.error(err))
      await sleep(60000); // "wait 1 minute between insertions and queries"
      let meta = await GDR.deployed();
      for (let index = 0; index < numSearches; index++) {
        console.time("query test");
        
        fields = textByLine[index].split("\t");
        let result = await meta.query.call(String(fields[0]), String(fields[1]), String(fields[2]));
        console.timeEnd("query test")
        //console.log(result);
        /*
        for (let x = 0; x < result.length; x++) { // test for accuracy
          assert.equal(
            result[x][0], String(fields[0]),
            "query result was wrong"
            );
          assert.equal(
            result[x][1], String(fields[1]),
            "query result was wrong"
            );
          assert.equal(
            result[x][2], String(fields[2]),
            "query result was wrong"
            );
        }
        */
      }
      //const qused = (process.memoryUsage().heapUsed / 1024 / 1024) - iused;
      //console.log(`query uses approximately ${Math.round(qused * 100) / 100} MB`);
    //disk.check(path)
    //.then(info => console.log(`post-query: ${info.free}`))
    //.catch(err => console.error(err))

  });

/*
for (var j = 0; j < numSearches; j++) {
      
      it("it tests the main query function: (gene * *)", function() {

      console.time("query test");
      GDR.deployed().then(function(instance) {
      gene_drug_repo = instance;

      var fields = textByLine[j].split("\t");
      return gene_drug_repo.query(String(fields[0]), "*", "*");
      //return gene_drug_repo.query.call("TNF", "41", "velaglucerase alfa"); // ("CALU", "*", "*") "FDPS", "11", "midazolam"
      }).then(function(result) {
          console.log(result);

          console.timeEnd("query test"); 
      });
  });
}
*/
  /*

        it("it tests the main query function: (gene var *)", function() {
      return GDR.deployed().then(function(instance) {
        var fs = require("fs");
        var text = fs.readFileSync("/Users/charlottebrannon/Desktop/new_truffle/contracts/Training_Data_1_Head.txt").toString('utf-8');
        var textByLine = text.split("\n");
        var arrayLength = textByLine.length;
      gene_drug_repo = instance;

        for (var i = 0; i < arrayLength; i++) {
          var fields = textByLine[i].split("\t");
          instance.query.call(fields[0], fields[1], "*");
        }
      //return gene_drug_repo.query.call("TNF", "41", "velaglucerase alfa"); // ("CALU", "*", "*") "FDPS", "11", "midazolam"

      }).then(function(structArray) {
          console.log(structArray);
          console.log("Should be the struct for [CALU, 91, gemcitabine]");
      });
  });

        it("it tests the main query function: (gene var drug)", function() {
      return GDR.deployed().then(function(instance) {
        var fs = require("fs");
        var text = fs.readFileSync("/Users/charlottebrannon/Desktop/new_truffle/contracts/Training_Data_1_Head.txt").toString('utf-8');
        var textByLine = text.split("\n");
        var arrayLength = textByLine.length;
      gene_drug_repo = instance;

        for (var i = 0; i < arrayLength; i++) {
          var fields = textByLine[i].split("\t");
          instance.query.call(fields[0], fields[1], fields[2]);
    
        }
      //return gene_drug_repo.query.call("TNF", "41", "velaglucerase alfa"); // ("CALU", "*", "*") "FDPS", "11", "midazolam"

      }).then(function(structArray) {
          console.log(structArray);
          console.log("Should be the struct for [CALU, 91, gemcitabine]");
      });
  });

*/
  });