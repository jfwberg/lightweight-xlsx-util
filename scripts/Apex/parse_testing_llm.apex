/** **************************************************************************************************** **
 *          Example 04 - Parse to an output that is optimised for LLMs
 ** **************************************************************************************************** **/
try{

   

    // As data map list
    String llmText = xlsx.Parse.toLlmText(
        new Compression.ZipReader(
            [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '069J900000DedA9IAJ' AND IsLatest = true LIMIT 1]?.VersionData
        ).getEntriesMap()
    );

    System.debug(llmText);
    
    
}catch(Exception e){
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage() + e.getStackTraceString());
}