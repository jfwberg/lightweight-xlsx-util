/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Examples on how to parse an XLSX file stored as a document
 * @examples       Parse to Multi-Dimensional Array and convert
 *                 the result to a list of CSV strings: one for each worksheet
 * @note           This method uses the toArrayInverted() method to have record
 *                 rows before columns instead of the other way around
 */
/** ********************************************************* **
 *     Parse to Multi-Dimensional Array and convert to CSV
 ** ********************************************************* **/
try{
    // A list of CSV strings, one for each workbook
    String[] csvStrings = new String[]{};
    
    // As data array
    for(Object[][] worksheet : xlsx.Parse.toArrayInverted(
        new Compression.ZipReader(
            [SELECT body FROM Document WHERE Id = '015Qz000004jf7yIAA' LIMIT 1]?.Body
        ).getEntriesMap()
    )){
        // Iterate trough each workbook
        csvStrings.add(multiDimensionalArrayToCsvString(worksheet));
    }

    // Output each CSV
    for(String worksheetAsCsv : csvStrings){
        System.debug(worksheetAsCsv);
    }
    
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


/**
 * @description Convert a multi-dimensional array to a CSV string
 * @param input The multi-dimensional array to convert
 */
String multiDimensionalArrayToCsvString(Object[][] input){
    
    // Create a list to hold each joined csv line
    String[] csvLines = new String[]{};

    // Apply CSV sanitization to each cell (CPU time intensive)
    for(Integer ri=0,riMax=input.size(); ri<riMax; ri++){
        for(Integer ci=0, ciMax=input[ri].size(); ci<ciMax; ci++){
            input[ri][ci] = ((String) input[ri][ci] ?? '').escapeCsv();
        }
    }

    // Join each individual line with sanitized fields
    for(Integer line=0, numLines=input.size(); line<numLines; line++){
        csvLines.add(String.join(input[line],','));
    }

    // Return all lines joined by a return character, you might want to update this based on your required output system
    return String.join(csvLines, '\n');
}