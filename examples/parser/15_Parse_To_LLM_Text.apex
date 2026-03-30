/** **************************************************************************************************** **
 *          Example 15 - Parse XLSX to a custom output format that is optimised for LLMs
 ** **************************************************************************************************** **/
try{
    // Parse to a string
    String llmText = xlsx.Parse.toLlmText(
        new Compression.ZipReader(
            [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '069Qz000006oKg2IAE' AND IsLatest = true LIMIT 1]?.VersionData
        ).getEntriesMap()
    );

    // Output the string
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