/** **************************************************************************************************** **
 *          Example 03 - Parse to Map with Sheet names and Multi-Dimensional Arrays for the data
 ** **************************************************************************************************** **/
try{
    // Example actions to perform
    Object  cellData;
    Integer cellCounter = 0;

    // As data map list
    Map<String, Object[][]> sheetNameArrayMap = xlsx.Parse.toSheetNameArrayInvertedMap(
        new Compression.ZipReader(
            [SELECT body FROM Document WHERE Id = '015Ae00000A5mEMIAZ' LIMIT 1]?.Body
        ).getEntriesMap(),
        new Set<Integer>{0,2}
    );

    // Loop through the worksheets and cells
    for(String sheetName :sheetNameArrayMap.keySet()){
        
        Object[][] sheetData = sheetNameArrayMap.get(sheetName);

        for(Integer ci=0, ciMax=sheetData.size(); ci<ciMax; ci++){
            for(Integer ri=0, riMax=sheetData[ci].size(); ri<riMax; ri++){
                
                // Do something with the cell data
                cellData = sheetData[ci][ri];

                // Increment the cell counter
                cellCounter++;
            }
        }
    }

    // Output the data in a human readable format
    System.debug(JSON.serializePretty(sheetNameArrayMap));

    // Output the number of cells
    System.debug(cellCounter + ' cells processed');

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