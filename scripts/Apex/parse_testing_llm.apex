/** **************************************************************************************************** **
 *          Example 04 - Parse to an output that is optimised for LLMs
 ** **************************************************************************************************** **/
try{

    // 015Ae00000A5mEMIAZ 12 days of christmas 
    // 015Ae00000A6ZmyIAF 50 k
    // 015Ae00000A6g5LIAR 100 k
    // 015Ae00000A6g6sIAB 150 k
    // 015Ae00000A6e9tIAB 200 k
    // 015Pt000009754DIAQ

    // As data map list
    Object llmText = xlsx.Parse.toMap(
        new Compression.ZipReader(
            //[SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '069Pt000008RSzjIAG' AND IsLatest = true LIMIT 1]?.VersionData
            [SELECT body FROM Document WHERE Id = '015Pt000009754DIAQ' LIMIT 1]?.Body
        ).getEntriesMap()
    );

    
    
}catch(Exception e){
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage() + e.getStackTraceString());
}