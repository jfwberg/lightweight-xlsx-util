/** **************************************************************************************************** **
 *          Example 04 - Parse to an output that is optimised for LLMs
 ** **************************************************************************************************** **/
try{

    // 015Ae00000A5mEMIAZ 12 days of christmas 
    // 015Ae00000A6ZmyIAF 50 k
    // 015Ae00000A6g5LIAR 100 k
    // 015Ae00000A6g6sIAB 150 k
    // 015Ae00000A6e9tIAB 200 k
    
    
    

    // As data map list
    Object llmText = xlsx.Parse.toLlmText(
        new Compression.ZipReader(
            [SELECT body FROM Document WHERE Id = '015Ae00000A6g5LIAR' LIMIT 1]?.Body
        ).getEntriesMap()
    );

    System.debug(llmText);
    
    

// Catch a Zip Specific Exception
}catch(Compression.ZipException e){
    System.debug('ZIP EXCEPTION: ' + e.getMessage());

// Catch an XLSX Parser Specific Exception
}catch(xlsx.ParseException e){
    System.debug('PARSE EXCEPTION: ' + e.getMessage());
    
// Catch and handle any other type of Exception
}catch(Exception e){
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage() + e.getStackTraceString());
}