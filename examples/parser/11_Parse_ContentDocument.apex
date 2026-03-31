/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Examples on how to parse an XLSX file stored as a document
 * @examples       - 01 - Parse to Multi-Dimensional Array and handle result
 *                 - 02 - Parse to List of Object Maps and handle result
 */
/** ********************************************************* **
 *          Example 01 - Parse to Multi-Dimensional Array
 ** ********************************************************* **/
try{
    // Example actions to perform
    Object  cellData;
    Integer cellCounter = 0;

    // As data array
    Object[][][] xlsxDataArray = xlsx.Parse.toArray(
        new Compression.ZipReader(
            [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '069Qz0000043co1IAA' AND IsLatest = true LIMIT 1]?.VersionData
        ).getEntriesMap()
    );

    // Loop through the worksheets, columns and rows to touch each cell
    for(Integer wi=0, wiMax=xlsxDataArray.size(); wi<wiMax; wi++){
        for(Integer ci=0, ciMax=xlsxDataArray[wi].size(); ci<ciMax; ci++){
            for(Integer ri=0, riMax=xlsxDataArray[wi][ci].size(); ri<riMax; ri++){

                // Do something with the cell data
                cellData = xlsxDataArray[wi][ci][ri];

                // Increment the cell counter
                cellCounter++;
            }
        }
    }

    // Output the data in a human readable format
    System.debug(JSON.serializePretty(xlsxDataArray));

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
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage());
}


/** ********************************************************* **
 *          Example 02 - Parse to Multi-Dimensional Array
 ** ********************************************************* **/
try{
    // Example actions to perform
    Object  cellData;
    Integer cellCounter = 0;

    // As data map list
    List<Map<String,Object>> xlsxDataMapList = xlsx.Parse.toMap(
        new Compression.ZipReader(
            [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = '069Qz0000043co1IAA' AND IsLatest = true LIMIT 1]?.VersionData
        ).getEntriesMap()
    );

    // Loop through the worksheets and cells
    for(Integer wi=0, wiMax=xlsxDataMapList.size(); wi<wiMax; wi++){
        for(String cKey : xlsxDataMapList[wi].keySet()){

            // Do something with the cell data
            cellData = xlsxDataMapList[wi].get(cKey);

            // Increment the cell counter
            cellCounter++;
        }
    }

    // Output the data in a human readable format
    System.debug(JSON.serializePretty(xlsxDataMapList));

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
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage());
}
    