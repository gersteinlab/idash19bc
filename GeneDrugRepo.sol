pragma solidity ^0.5.8;
pragma experimental ABIEncoderV2;

contract GeneDrugRepo {

// 22 AUGUST 2019
// GAMZE GURSOY & CHARLOTTE BRANNON
// YALE UNIVERSITY
// IDASH TRACK 1 SUBMISSION
//**********************************************************************************************
// DEFINE STRUCTS
//**********************************************************************************************

    // This structure is how the data should be returned from the query function.
    // You do not have to store relations this way in your contract, only return them.
    // geneName and drugName must be in the same capitalization as it was entered. E.g. if the original entry was GyNx3 then GYNX3 would be considered incorrect.
    // Percentage values must be acurrate to 6 decimal places and will not include a % sign. E.g. "35.123456"
    struct GeneDrugRelation {
        string geneName;
        uint variantNumber;
        string drugName;
        uint totalCount;
        uint improvedCount;
        string improvedPercent;
        uint unchangedCount;
        string unchangedPercent;
        uint deterioratedCount;
        string deterioratedPercent;
        uint suspectedRelationCount;
        string suspectedRelationPercent;
        uint sideEffectCount;
        string sideEffectPercent;
    }
    // struct to hold the data in storage database
    struct GeneDrugStruct {
        bytes32 geneNameField;
        bytes32 variantNumberField;
        string drugNameField;
        bytes32 outcomeField;
        bool suspectedRelationField;
        bool seriousSideEffectField;
        uint index;
        address whoAdded;
    }
    // struct to hold unique gene-var-drug combos
    struct UniqueNames {
    	bytes32 geneName;
    	bytes32 variantNumber;
    	string drugName;
    }
    // struct to check which fields were queried
    struct BoolStruct {
        bool gene;
        bool variant;
        bool drug;
    }

//**********************************************************************************************
// INITIALIZE MAPPINGS AND ARRAYS
//**********************************************************************************************

    // mappings and corresponding arrays to hold data values and their keys, respectively
    mapping (bytes32 => uint[]) geneNames; //key = geneName
    mapping (bytes32 => uint[]) variantNumbers; //key = variantNumber
    mapping (string => uint[]) drugNames; //key = drugName

    mapping (uint => GeneDrugStruct) database;
    // counter to assign each entry a unique index
    uint counter;
    // array to hold the unique geneName-variant-drug entries
    UniqueNames[] uniqueNamesArray;
    // parameters for toString()
    uint prec_all = 8; 
    uint prec_digits = 2;

//**********************************************************************************************
// CORE FUNCTIONS
//**********************************************************************************************

    /*  Insert an observation into your contract, following the format defined in the data readme. 
        This function has no return value. If it completes it will be assumed the observations was recorded successfully. 
        Note: case matters for geneName and drugName. GyNx3 and gynx3 are treated as different genes.
    */
    function insertObservation (
        string memory geneName,
        uint variantNumber,
        string memory drugName,
        string memory outcome,  // IMPROVED, UNCHANGED, DETERIORATED. This will always be capitalized, you don't have to worry about case. 
        bool suspectedRelation,
        bool seriousSideEffect
    ) public { 

        bytes32 name = toBytes32(geneName);
        bytes32 variant = toBytes32(toStringSimple(variantNumber));
        bytes32 outco = toBytes32(outcome);
        address who = msg.sender;

        // check if the gene-variant-drug combo already exists in the database. If not, add it to the uniqueNamesArray
        if (entryExists(geneName, toStringSimple(variantNumber), drugName) == false) {
            uniqueNamesArray.push(UniqueNames(name, variant, drugName));
        }
        // update the four mappings
        geneNames[name].push(counter);
        variantNumbers[variant].push(counter);
        drugNames[drugName].push(counter);
        database[counter] = GeneDrugStruct(name, variant, drugName, outco, suspectedRelation, seriousSideEffect, counter, who);
        // update global counter/index
        counter++;
    }


    /*  Takes geneName, variant-number, and drug-name as strings. A value of "*" for any name should be considered as a wildcard or alternatively as a null parameter.
        Returns: An array of GeneDrugRelation Structs which match the query parameters
        To clarify here are some example queries:
        query("CYP3A5", "52", "pegloticase") => An array of the one relation that matches all three parameters
        query("CYP3A5","52","*") => An array of all relations between geneName, CYP3A5, variant 52, and any drug
        query("CYP3A5","*","pegloticase") => An array of all relations between geneName, CYP3A5 and drug pegloticase, regardless of variant
        query("*","*","*") => An array of all known relations. 
        Note that capitalization matters. 
    */
 function query(
        string memory geneName,
        string memory variantNumber,
        string memory drug
    ) public view returns (GeneDrugRelation[] memory) {
        // initialize memory structs and variables
        uint numFields;
        BoolStruct memory starInfo;
        GeneDrugRelation[] memory empty;
        uint[] memory geneNameSearch;
        uint[] memory variantNumberSearch;
        uint[] memory drugNameSearch;
        uint[] memory indexSearch = new uint[](counter);
        UniqueNames[] memory uniqueSearch = new UniqueNames[](uniqueNamesArray.length);

        // if database is empty, return empty array
        if (counter == 0) { //|| entryExists(geneName, variantNumber, drug) == false) { 
            return empty;
        }
        // count the number of fields used to search
        if (compareStrings(geneName, "*") == false) { // if geneName field was not "*", increase numFields & mark geneName true in starInfo struct
            geneNameSearch = geneNames[toBytes32(geneName)];
            numFields++;
            starInfo.gene = true;
        }
        if (compareStrings(variantNumber, "*") == false) { // if variantNumber field was not "*", increase numFields & mark variantNumber true in starInfo struct
            variantNumberSearch = variantNumbers[toBytes32(variantNumber)];
            numFields++;
            starInfo.variant = true;
        }
        if (compareStrings(drug, "*") == false) { // if drug field was not "*", increase numFields & mark drug true in starInfo struct
            drugNameSearch = drugNames[drug];
            numFields++;
            starInfo.drug = true;
        }

        uint matchCount; // num entries in the database that matched the query
        uint uniqueCount; // num unique gene-variant-drug combos in the query results

        if ((compareStrings(geneName, "*") == true) && 
            (compareStrings(variantNumber, "*") == true) && 
            (compareStrings(drug, "*") == true)
            ) {
            matchCount = counter;
            uniqueCount = uniqueNamesArray.length;
            uniqueSearch = uniqueNamesArray;
            for (uint i; i < counter; i++) {
                indexSearch[i] = i;
            }
        } else {
            uint min = counter;
            uint which_one = 3;
            if (geneNameSearch.length <= min && geneNameSearch.length != 0){
                min = geneNameSearch.length;
                which_one = 0;
            }
            if (variantNumberSearch.length <= min && variantNumberSearch.length != 0){
                min = variantNumberSearch.length;
                which_one = 1;
            }
            if (drugNameSearch.length <= min && drugNameSearch.length != 0){
                min = drugNameSearch.length;
                which_one = 2;
            }
            if (geneNameSearch.length == variantNumberSearch.length && variantNumberSearch.length == drugNameSearch.length) {
                min = geneNameSearch.length;
                which_one = 0;
            }

            for (uint i; i < min; i++) {
                uint found = 1;
                //if shortest array is genenamesearch
                if (which_one == 0) {
                    if (starInfo.variant == true) {
                        for (uint j; j < variantNumberSearch.length; j++){
                            if (geneNameSearch[i] == variantNumberSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.drug == true) {
                        for (uint j; j < drugNameSearch.length; j++){
                            if (geneNameSearch[i] == drugNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields){
                        indexSearch[matchCount] = geneNameSearch[i];
                        matchCount++;
                        GeneDrugStruct memory addMe = database[geneNameSearch[i]];
                        if (entryExistsCustom(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField, uniqueSearch) == false) {
                            uniqueSearch[uniqueCount] = UniqueNames(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField);
                            uniqueCount++;
                        }
                    }
                }
                //if shortest array variantnumbersearch
                if (which_one == 1){
                    if (starInfo.gene == true) {
                        for (uint j; j < geneNameSearch.length; j++){
                            if (variantNumberSearch[i] == geneNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.drug == true) {
                        for (uint j; j < drugNameSearch.length; j++){
                            if (variantNumberSearch[i] == drugNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields){
                        indexSearch[matchCount] = variantNumberSearch[i];
                        matchCount++;
                        GeneDrugStruct memory addMe = database[variantNumberSearch[i]];
                        if (entryExistsCustom(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField, uniqueSearch) == false) {
                            uniqueSearch[uniqueCount] = UniqueNames(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField);
                            uniqueCount++;
                        }
                    }
                }
                //if shortest array is drugnamesearch
                if (which_one == 2){
                    if (starInfo.variant == true) {
                        for (uint j; j < variantNumberSearch.length; j++){
                            if (drugNameSearch[i] == variantNumberSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.gene == true) {
                        for (uint j; j < geneNameSearch.length; j++){
                            if (drugNameSearch[i] == geneNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields){
                        indexSearch[matchCount] = drugNameSearch[i];
                        matchCount++;
                        GeneDrugStruct memory addMe = database[drugNameSearch[i]];
                        if (entryExistsCustom(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField, uniqueSearch) == false) {
                            uniqueSearch[uniqueCount] = UniqueNames(addMe.geneNameField, addMe.variantNumberField, addMe.drugNameField);
                            uniqueCount++;
                        }
                    }
                }
            }
        }
        // trim arrays to increase looping efficiency
        uint[] memory trimIndexSearch = new uint[](matchCount);
        UniqueNames[] memory trimUniqueSearch = new UniqueNames[](uniqueCount);
        for (uint i; i < matchCount; i++) {
            trimIndexSearch[i] = indexSearch[i];
        }
        for (uint j; j < uniqueCount; j++) {
            trimUniqueSearch[j] = uniqueSearch[j];
        }

        // build final struct from search results
        GeneDrugRelation[] memory matches = new GeneDrugRelation[](uniqueCount); // final struct array
        uint tally; // num entries for a given gene-variant-drug combo
        for (uint a; a < trimUniqueSearch.length; a++){
            uint[] memory sameThing = new uint[](counter);
            tally = 0;
            for (uint b; b < matchCount; b++) {
                 // number of matches per unique combo
                if ((trimUniqueSearch[a].geneName == database[trimIndexSearch[b]].geneNameField) && 
                    (trimUniqueSearch[a].variantNumber == database[trimIndexSearch[b]].variantNumberField) && 
                    compareStrings(trimUniqueSearch[a].drugName, database[trimIndexSearch[b]].drugNameField)
                    ) {
                    sameThing[tally] = trimIndexSearch[b]; // add search result to sameThing if it matches uniqueSearch a
                    tally++;
                }
            }
            // loop through trimmedThing to compile the counts for this struct entry
            for (uint c; c < tally; c++) {
                if (database[sameThing[c]].outcomeField == toBytes32("IMPROVED")) {
                    matches[a].improvedCount++;
                } else if (database[sameThing[c]].outcomeField == toBytes32("UNCHANGED")) {
                    matches[a].unchangedCount++;
                } else if (database[sameThing[c]].outcomeField == toBytes32("DETERIORATED")) {
                    matches[a].deterioratedCount++;
                }
                if (database[sameThing[c]].suspectedRelationField == true) {
                    matches[a].suspectedRelationCount++;
                }
                if (database[sameThing[c]].seriousSideEffectField == true) {
                    matches[a].sideEffectCount++;
                }
            }
            matches[a].geneName = toShortString32(database[sameThing[0]].geneNameField);
            matches[a].variantNumber = toInt(toShortString32(database[sameThing[0]].variantNumberField));
            matches[a].drugName = database[sameThing[0]].drugNameField;
            matches[a].totalCount = tally;
            matches[a].improvedPercent = makePercentageString(matches[a].improvedCount, matches[a].totalCount);
            matches[a].unchangedPercent = makePercentageString(matches[a].unchangedCount, matches[a].totalCount);
            matches[a].deterioratedPercent = makePercentageString(matches[a].deterioratedCount, matches[a].totalCount);
            matches[a].suspectedRelationPercent = makePercentageString(matches[a].suspectedRelationCount, matches[a].totalCount);
            matches[a].sideEffectPercent = makePercentageString(matches[a].sideEffectCount, matches[a].totalCount);
        }
        return matches; // final struct array of GeneDrugRelation structs
    }


    //   Takes: geneName,-name, variant-number, and drug-name as strings. Accepts "*" as a wild card, same rules as query
    //   Returns: A boolean value. True if the relation exists, false if not. If a wild card was used, then true if any relation exists which meets the non-wildcard criteria.
   function entryExists(
        string memory geneName,
        string memory variantNumber,
        string memory drug
    ) public view returns (bool){
         // initialize memory structs and variables
        uint numFields;
        uint[] memory geneNameSearch;
        uint[] memory variantNumberSearch;
        uint[] memory drugNameSearch;
        
        BoolStruct memory starInfo;
        // if database is empty, return empty array
        if (counter == 0) { 
            return false;
        }

        // count the number of fields used to search
        if (compareStrings(geneName, "*") == false) { 
            numFields++;
            starInfo.gene = true;
            geneNameSearch = geneNames[toBytes32(geneName)];
        }
        if (compareStrings(variantNumber, "*") == false) { 
            numFields++;
            starInfo.variant = true;
            variantNumberSearch = variantNumbers[toBytes32(variantNumber)];
        }
        if (compareStrings(drug, "*") == false) {
            numFields++;
            starInfo.drug = true;
            drugNameSearch = drugNames[drug];
        }

        if ((compareStrings(geneName, "*") == true) && 
            (compareStrings(variantNumber, "*") == true) && 
            (compareStrings(drug, "*") == true)
            ) {
            return true;
           
        } else {
            uint min = counter;
            uint which_one = 3;
            if (geneNameSearch.length <= min && geneNameSearch.length != 0){
                min = geneNameSearch.length;
                which_one = 0;
            }
            if (variantNumberSearch.length <= min && variantNumberSearch.length != 0){
                min = variantNumberSearch.length;
                which_one = 1;
            }
            if (drugNameSearch.length <= min && drugNameSearch.length != 0){
                min = drugNameSearch.length;
                which_one = 2;
            }
            if (geneNameSearch.length == variantNumberSearch.length && variantNumberSearch.length == drugNameSearch.length) {
                min = geneNameSearch.length;
                which_one = 0;
            }
            uint found;
            for (uint i; i < min; i++) {
                found = 1;
                //if shortest array is genenamesearch
                if (which_one == 0) {
                    if (starInfo.variant == true) {
                        for (uint j; j < variantNumberSearch.length; j++){
                            if (geneNameSearch[i] == variantNumberSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.drug == true) {
                        for (uint j; j < drugNameSearch.length; j++){
                            if (geneNameSearch[i] == drugNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields) {
                        break;
                    }
                }
                //if shortest array variantnumbersearch
                if (which_one == 1){
                    if (starInfo.gene == true) {
                        for (uint j; j < geneNameSearch.length; j++){
                            if (variantNumberSearch[i] == geneNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.drug == true) {
                        for (uint j; j < drugNameSearch.length; j++){
                            if (variantNumberSearch[i] == drugNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields){
                        break;
                    }
                }
                //if shortest array is drugnamesearch
                if (which_one == 2){
                    if (starInfo.variant == true) {
                        for (uint j; j < variantNumberSearch.length; j++){
                            if (drugNameSearch[i] == variantNumberSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (starInfo.gene == true) {
                        for (uint j; j < geneNameSearch.length; j++){
                            if (drugNameSearch[i] == geneNameSearch[j]){
                                found++;
                                break;
                            }
                        }
                    }
                    if (found == numFields){
                        break;
                    }
                }
            }
            if (found == numFields){
                return true;
            }
            else{
                return false;
            }
        }
    }
    

    //  Return the total number of known relations, a.k.a. the number of unique geneName,-name, variant-number, drug-name pairs
    function getNumRelations () public view returns(uint){
        return uniqueNamesArray.length;
    }
    

    //  Return the total number of recorded observations, regardless of sender.
    function getNumObservations() public view returns (uint) {
        return counter;
    }


    //  Takes: A wallet address.
    //  Returns: The number of observations recorded from the provided wallet address
    function getNumObservationsFromSender(address sender) public view returns (uint) {
        uint count;
        for (uint i = 0; i < counter; i++) {
            if (database[i].whoAdded == sender) {
                count++;
            }
        }
        return count;
    }


//**********************************************************************************************
// AUXILARY METHODS
//**********************************************************************************************

    /*  CMB: function to generate a string representation of a percentage, e.g. "1.123456"
        Calls toString() function.
    */
    function makePercentageString (
        uint count,
        uint total_count
        ) internal view returns (string memory percentString) {
        // improved percent
        uint div = percent(count, total_count, prec_digits); // get the percentage with low precision to determine the number of digits
        uint percent_div = percent(count, total_count, prec_all); // get the percentage with high precision to determine the decimal values
        if (count == 0) { // if the count was 0, just assign "0.000000" as the answer
            return "0.000000";
        } else {
            if (total_count / count > 100) { // if the answer is going to be <1%
                return toString(percent_div, numDigits(percent_div) + 1, true, prec_all);
            } else {
                return toString(percent_div, numDigits(div), false, prec_all); // if the answer is going to be >=1%
            }
        }
    }


    /*  CMB: function to check if a gene-variant-drug combo exists in a UniqueNames[] array
        Returns: A boolean value. True if the relation exists, false if not.
    */
    function entryExistsCustom (
        bytes32 geneName,
        bytes32 variantNumber,
        string memory drug,
        UniqueNames[] memory array) internal pure returns (bool){
        if (array.length == 0) {
            return false;
        } 
        uint searcher; 
        for (uint j; j < array.length; j++) {
            if (array[j].geneName == geneName && array[j].variantNumber == variantNumber && compareStrings(array[j].drugName, drug) == true) {
                searcher++;
                break;
            }
        }
        if (searcher == 1){
            return true;
        } else {
            return false;
        }
    }
//**********************************************************************************************
// BASIC UTILITIES
//**********************************************************************************************

    /*  CMB: function to convert uints to strings
        from https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
        edited by CMB for the percentage string case.
    */
    function toString(
        uint _base, 
        uint numDigits, 
        bool lessThanOne, 
        uint precision
        ) internal pure returns (string memory) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i; _base > 0; i++) {
            _tmp[i] = byte(uint8((_base % 10) + 48));
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        bytes memory deci_real = new bytes(_real.length + numDigits);
        if (precision != 0) {
            uint count;
            uint tally;
            for (uint k; k < deci_real.length; k++) {
                if (lessThanOne == true) {
                    if (k < precision) {
                        if (k == 0) {
                            deci_real[count] = "0";
                            count++;
                        } else if (k ==1) {
                            deci_real[count] = ".";
                            count++;
                        } else if (k!=0 && k!= 1 && k < (precision - (numDigits - 1))) {
                            deci_real[count] = "0";
                            count++;
                        } else if (k!=0 && k!= 1 && k >= (precision - (numDigits - 1))) {
                            deci_real[count] = _real[tally];
                            tally++;
                            count++;
                        }
                    }
                } else {
                    if (k == numDigits) {
                        deci_real[count] = ".";
                        count++;
                        deci_real[count] = _real[k];
                        count++;
                    } else if (k < _real.length) {
                        deci_real[count] = _real[k];
                        count++;
                    }
                }
            }
            bytes memory bytesContainerTrimmed = new bytes(count);
            for (uint256 charCounter; charCounter < count; charCounter++) {
                bytesContainerTrimmed[charCounter] = deci_real[charCounter];
            }
            return string(bytesContainerTrimmed);
        }
        return string(_real);
    }

    /*  CMB: function to convert uints to strings
        from https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
    */
    function toStringSimple(uint _base) internal pure returns (string memory) {
        bytes memory _tmp = new bytes(32);
        uint i;
        for(i; _base > 0; i++) {
            _tmp[i] = byte(uint8((_base % 10) + 48));
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for(uint j; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }

    /*  CMB: function to return the number of digits in a uint
        from https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
    */
    function numDigits(uint number) internal pure returns (uint result) {
        uint digits;
        while (number != 0) {
            number /= 10;
            digits++;
        }
        return digits;
    }

    /*  CMB: function to divide two uints and return an answer with high precision
    */
    function percent(
        uint numerator, 
        uint denominator, 
        uint precision
        ) internal pure returns(uint quotient) {
        uint _numerator  = numerator * 10 ** (precision+1);
        uint _quotient =  ((_numerator / denominator + 5) / 10);
        return (_quotient);
    }

    /*  CMB: function to convert a string to a uint
        from https://github.com/willitscale/solidity-util/blob/master/lib/Integers.sol
    */
    function toInt(string memory _value) internal pure returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(uint8(_bytesValue[i]) >= 48 && uint8(_bytesValue[i]) <= 57);
            _ret += (uint8(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }

    /*  CMB: function to compare two strings
    */
    function compareStrings(
    	string memory a, 
    	string memory b
    	) internal pure returns (bool){ 
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)))); 
    }

    /*  CMB: function to convert a string to bytes32 data type
    */
  	function toBytes32(string memory _string) internal pure returns (bytes32) {
   		bytes32 _stringBytes;
    	assembly {
      	_stringBytes := mload(add(_string, 32))
    	}
    	return _stringBytes;
  	}
    
    /*  CMB: function to convert a bytes32 to string data type
    */
	function toShortString32(bytes32 _data) internal pure returns (string memory) {
    	bytes memory _bytesContainer = new bytes(32);
    	uint256 _charCount;
    	for (uint256 _bytesCounter; _bytesCounter < 32; _bytesCounter++) {
      		bytes1 _char = bytes1(bytes32(uint256(_data) * 2 ** (8 * _bytesCounter)));
      		if (_char != 0) {
        		_bytesContainer[_charCount] = _char;
       			_charCount++;
      		}
    	}
    	bytes memory _bytesContainerTrimmed = new bytes(_charCount);
    	for (uint256 _charCounter; _charCounter < _charCount; _charCounter++) {
      		_bytesContainerTrimmed[_charCounter] = _bytesContainer[_charCounter];
    	}
    	return string(_bytesContainerTrimmed);
 	}

} // END OF CONTRACT
