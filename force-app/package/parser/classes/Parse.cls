/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    A class to holds an example of how you can parse an XLSX
 *                 worksheet data into a multi-dimensional array or into a list of maps
 *
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 *
 * @parser rules   - The worksheet should have the "dimensions" element populated
 *                 - Formula fields are NOT recalculated, so they need to contain the correct value
 *                 - You work with raw data so hidden and (password) protected rows and columns will be parsed
 *                 - Password encrypted sheets are not supported
 *
 * @Notes          - There are no checks if the XLSX files are valid
 *                 - The Shared String Indexes are not tested for out of bounds violations due to performance
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Parse{

    /** **************************************************************************************************** **
     **                                       GLOBAL WORKSHEET METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Method that creates a map with the sheet name as key and the
     *              sheet index as the value
     *              This is to be used if you don't know the sheet order but do know the name
     * @param  entries A map of path/zip entries from the unzipped XLSX file
     * @return         A map with the sheet name as key and the index as value
     */
    global static Map<String,Integer> toWorksheetNameIndexMap(Map<String,Compression.ZipEntry> entries){
        return toWorksheetNameIndexMap(entries,null);
    }


    /**
     * @description Method that creates a map with the sheet name as key and the
     *              sheet index as the value
     *              This is to be used if you don't know the sheet order but do know the name
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes
     * @return      A map with the sheet name as key and the index as value
     */
    global static Map<String,Integer> toWorksheetNameIndexMap(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Validate the workbook file exists
        if(!entries.containsKey(Constant.ZP_PATH_WORKBOOK)){
            throw new ParseException(String.format(Constant.MSG_INVALID_ZIP_ENTRY, new String[]{Constant.ZP_PATH_WORKBOOK}));
        }

        // List of sheet indexes to create to proper order
        SheetIndex[] sheetIndexes = new SheetIndex[]{};

        // Create an XSR for the current worksheet XML file
        XmlStreamReader xsr = new XmlStreamReader(entries.get(Constant.ZP_PATH_WORKBOOK).getContent().toString().replace('\uFEFF', ''));

        // Traverse the XML elements in the worksheet
        // I am not using while(xsr.hasNext()) to save a method call at the end of each item
        // For some reason it's about 30% faster to put an if statement at the end. No idea why.
        while(true){

            // Start at the beginning of the book and make sure that it is a book
            if (xsr.getEventType() == XmlTag.START_ELEMENT) {

                // Get the sheet element and create a new SheetIndex object for each sheet so we can sort it
                switch on xsr.getLocalName(){
                    when 'sheet'{
                        sheetIndexes.add(
                            new SheetIndex(
                                Integer.valueOf(xsr.getAttributeValue(null, 'sheetId')),
                                xsr.getAttributeValue(null, 'name')
                            )
                        );
                    }
                }
            }

            // If there is a next element go to the next element, else we're done
            if(xsr.hasNext()){ xsr.next(); } else { break; }
        }

        // Sort the sheet indexes
        sheetIndexes.sort();

        // Create a map for the output
        Map<String,Integer> worksheetNameIndexMap = new Map<String,Integer>();

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // populate the output map
        for(Integer wi=0,wiMax=sheetIndexes.size();wi<wiMax;wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Add the name at the new worksheet index because some have been deleted
            worksheetNameIndexMap.put(sheetIndexes[wi].name, currentWi);
        }

        // Return the output map
        return worksheetNameIndexMap;
    }


    /**
     * @description Method that creates a map with the sheet Index as key and the
     *              sheet name as the value
     *              This is to be used if you don't know the sheet order but do know the name
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @return      A map with the sheet name as key and the index as value
     */
    global static Map<Integer,String> toWorksheetIndexNameMap(Map<String,Compression.ZipEntry> entries){
        return toWorksheetIndexNameMap(entries,null);
    }


    /**
     * @description Method that creates a map with the sheet Index as key and the
     *              sheet name as the value
     *              This is to be used if you don't know the sheet order but do know the name
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes
     * @return      A map with the sheet name as key and the index as value
     */
    global static Map<Integer,String> toWorksheetIndexNameMap(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){
        
        // Create a map for the output
        Map<Integer,String> worksheetIndexNameMap = new Map<Integer,String>();

        // Create the worksheet index map using the main logic
        Map<String,Integer> worksheetNameIndexMap = toWorksheetNameIndexMap(entries,selectedSheets);

        // Invert the map
        for(String worksheetName : worksheetNameIndexMap.keySet()){
            worksheetIndexNameMap.put(worksheetNameIndexMap.get(worksheetName), worksheetName);
        }

        // Return the inverted map
        return worksheetIndexNameMap;
    }


    /** **************************************************************************************************** **
     **                                         GLOBAL ARRAY METHODS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries A map of path/zip entries from the unzipped XLSX file
     * @return      A list of sheets with a list of rows with a list of cell
     * @note        Use this method for the large sheets
     */
    global static Object[][][] toArray(Map<String,Compression.ZipEntry> entries){
        return toArray(entries, null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        Use this method for the large sheets
     */
    global static Object[][][] toArray(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create a multi-dimensional array for the output
        // Worksheet - Column - Row
        Object[][][] output = new Object[][][]{};

        // Create a list of shared strings
        String[] sharedStrings = getSharedStrings(entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of the largest number of columns. If one sheet is larger than the other
        // we do not do have a duplicate translation for overlapping column names
        // i.e. If sheet 1 has 10 columns and sheet 2 has 20 columns, make sure to only
        // translate the column names from 11 to 20 to save some CPU time
        Integer maxNumberOfColumnsInAllWorksheets = 0;

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi =0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Add array for the sheet to hold the columns and rows
            output.add(new Object[][]{});

            // Create an XSR for the current worksheet XML file
            XmlStreamReader xsr = new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', ''));

            // Set the current row to -1 so the indexes match
            Integer currentRi = -1;

            // Variables to hold the type and name of the current open cell element
            String cellType;
            String columnName;

            // Google sheets does not include the dimension attribute, so we need to 
            // figure out the dimensions in a different less efficient way
            Boolean hasDimensionAttribute = false;

            // Traverse the XML elements in the worksheet
            // I am not using while(xsr.hasNext()) to save a method call at the end of each item
            // For some reason it's about 30% faster to put an if statement at the end. No idea why.
            while(true) {

                // Start at the beginning of the book and make sure that it is a book
                if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                    switch on xsr.getLocalName() {

                        // First we need the dimension of the worksheet to find out the max size of our rows
                        // The order in the XML is mandatory, so this value should exist, if not the sheet is invalid
                        when 'dimension'{
                            
                            // Indicate we have a dimensions attribute
                            hasDimensionAttribute = true;

                            // Get the cell name from the range, the ref attribute is mandatory so should be there
                            // The ref value can be either in the format "A1:C3"
                            // or simply the intersecting cell only... i.e. "C3"
                            String cName = xsr.getAttributeValueAt(0)?.contains(':')     ? 
                                                xsr.getAttributeValueAt(0).split(':')[1] :
                                                xsr.getAttributeValueAt(0)
                            ;

                            // Safeguard: if the ref attribute is empty, ignore the dimension attribute
                            // and move on to manually calculate the number of rows
                            if(String.isBlank(cName) || cName?.toLowerCase() == Constant.DEF_SNGL_DIMENSION){
                                hasDimensionAttribute = false;
                            }

                            // Get the ref element from the token and calculate the value
                            String colName = ParseUtil.columnNameFromCellName(cName);

                            // Get the number of columns and rows that are in this worksheet
                            Integer numCols = CommonUtil.columnNumberFromColumnName(colName);
                            Integer numRows = Integer.valueOf(cName.removeStart(colName));

                            // Pre-populate a map with the column name related to the column index i.e. AA => 27, AB =>28 etc
                            // Prepopulating makes the parsing go a lot faster as we only have to calculate it once
                            if(numCols > maxNumberOfColumnsInAllWorksheets){

                                // Populate the column index (startnumber and the total number of columns)
                                ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numCols);

                                // Update to the new max column dimension
                                maxNumberOfColumnsInAllWorksheets = numCols;
                            }

                            // Add empty values for each (potential cell)
                            for(Integer ci=0; ci<numCols; ci++){

                                // Pre-populate the entire "grid" with empty lists and null values
                                output[currentWi].add(new Object[]{});

                                // Create a new entry for the row
                                for(Integer ri=0; ri<numRows; ri++){
                                    output[currentWi][ci].add(null);
                                }
                            }
                        }

                        // The first element after dimension where we can check
                        // only once that there is a dimension attribute
                        when 'sheetData'{
                            
                            // If we have no dimension attribute we'll have to figure out
                            // the last column and rows based on iterating the entire sheet
                            if(!hasDimensionAttribute){
                                ParseUtil.populateColumnIndexMapWithoutDimensionAttribute(
                                    new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', '')),
                                    currentWi,
                                    output,
                                    false // Inverted
                                );
                            }
                        }

                        // The row element, keep track of what row we're currently in
                        // We can have a situation where we have row 1 and 10 populated, but nothing in between
                        when 'row'{
                            currentRi = Integer.valueOf(xsr.getAttributeValue(null, 'r'))-1;
                        }

                        // The cell element
                        when 'c' {
                            columnName = ParseUtil.columnNameFromCellName(xsr.getAttributeValue(null, 'r'));
                            cellType   = xsr.getAttributeValue(null, 't');
                        }

                        // Value tags inside the cell element
                        when 'v','t'{

                            // Skip to the text element
                            xsr.next();

                            // Validate we're in a text element
                            if(xsr.getEventType() == XmlTag.CHARACTERS){

                                // Put the cell value in array at location wi.ci.ri
                                // If there is a "sharedStrings index", get the shared strings value at that index
                                // else the value in the value in the XSR
                                output[currentWi][ParseUtil.columnIndexMap.get(columnName)][currentRi] = (cellType == 's') ? sharedStrings[Integer.valueOf(xsr.getText())] : xsr.getText();
                            }
                        }
                    }
                }

                // If there is a next element go to the next element, else we're done
                if(xsr.hasNext()){ xsr.next(); } else { break; }
            }
        }

        // Return the sheets data as a multi dimensional array
        return output;
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries A map of path/zip entries from the unzipped XLSX file
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static Object[][][] toArrayDomDoc(Map<String,Compression.ZipEntry> entries){
        return toArrayDomDoc(entries, null);
    }


    /**
     * @description A method to parse the XML using the DOM.Document classes. There is a trade-off in the max size
     *              but this method is significantly faster on the CPU time.
     * @param entries        A map of path/zip entries from the unzipped XLSX file
     * @param selectedSheets A set of sheet indexes that are to be parsed
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        I have optimized this method to being able to handle as much data as possible
     *              this meant that some data is in variable to achieve this. With magical results.
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static Object[][][] toArrayDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create a multi-dimensional array for the output
        // Worksheet - Column - Row
        Object[][][] output = new Object[][][]{};

        // Create a list of shared strings
        String[] sharedStrings = getSharedStrings(entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of the largest number of columns. If one sheet is larger than the other
        // we do not do have a duplicate translation for overlapping column names
        // i.e. If sheet 1 has 10 columns and sheet 2 has 20 columns, make sure to only
        // translate the column names from 11 to 20 to save some CPU time
        Integer maxNumberOfColumnsInAllWorksheets = 0;

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi=0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Add array for the sheet to hold the columns and rows
            output.add(new Object[][]{});

            // Create a DOM document for reading
            Dom.Document doc = new Dom.Document();

            // Load the XML
            doc.load(entries.get(worksheetPaths[wi]).getContent().toString());

            // Extract the dimension
            Dom.XmlNode dimension = doc.getRootElement().getChildElement('dimension', Constant.NS_SPREADSHEET_ML);

            // Get the number of columns / rows for this sheet
            Integer numberOfColumnsInCurrentWorksheet = 0;
            Integer numberOfRowsInCurrentWorksheet    = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements().size();

            // We know the number of rows, if there is no dimension element we need to figure out the largest
            // cell in any of the rows. To do this we read the last cell in each row and get the column number
            if(dimension == null || dimension != null && String.isBlank(dimension.getAttributeValue('ref', null))){
                for(Integer ri=0;ri<numberOfRowsInCurrentWorksheet; ri++){

                    // Extracting the row/cell reduces the CPU time by 50%, and for some weird reason improves the max heap size
                    Dom.XmlNode row  = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements()[ri];
                    Dom.XmlNode cell = row.getChildElements()[row.getChildElements().size()-1];

                    // Get the last column number
                    Integer lastColumnNumberInCurrentRow = CommonUtil.columnNumberFromColumnName(
                        ParseUtil.columnNameFromCellName(
                            cell.getAttributeValue('r', null)
                        )
                    );

                    // Update the largest column number in the worksheet if the one in the current row is the highest
                    if(numberOfColumnsInCurrentWorksheet < lastColumnNumberInCurrentRow){
                        numberOfColumnsInCurrentWorksheet = lastColumnNumberInCurrentRow;
                    }
                }

                // Populate the column index (startnumber and the total number of columns)
                // Keep track of the largest column number over all the worksheets
                if(numberOfColumnsInCurrentWorksheet > maxNumberOfColumnsInAllWorksheets){
                    ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numberOfColumnsInCurrentWorksheet);
                    maxNumberOfColumnsInAllWorksheets = numberOfColumnsInCurrentWorksheet;
                }
            }else{
                
                // Get the cell name from the range, the ref attribute is mandatory so should be there
                // The ref value can be either in the format "A1:C3"
                // or simply the intersecting cell only... i.e. "C3"
                String cName = dimension.getAttributeValue('ref', null) ?.contains(':')    ? 
                                    dimension.getAttributeValue('ref', null).split(':')[1] :
                                    dimension.getAttributeValue('ref', null)
                ;

                // Get the ref element from the token and calculate the value
                String colName = ParseUtil.columnNameFromCellName(cName);

                // Get the number of columns and rows that are in this worksheet
                numberOfColumnsInCurrentWorksheet = CommonUtil.columnNumberFromColumnName(colName);
                
                // Pre-populate a map with the column name related to the column index i.e. AA => 27, AB =>28 etc
                // Prepopulating makes the parsing go a lot faster as we only have to calculate it once
                if(numberOfColumnsInCurrentWorksheet > maxNumberOfColumnsInAllWorksheets){

                    // Populate the column index (startnumber and the total number of columns)
                    ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numberOfColumnsInCurrentWorksheet);

                    // Update to the new max column dimension
                    maxNumberOfColumnsInAllWorksheets = numberOfColumnsInCurrentWorksheet;
                }
            }

            // Add empty values for each (potential cell)
            for(Integer ci=0; ci<numberOfColumnsInCurrentWorksheet; ci++){

                // Pre-populate the entire "grid" with empty lists and null values
                output[currentWi].add(new Object[]{});

                // Create a new entry for the row
                for(Integer ri=0; ri<numberOfRowsInCurrentWorksheet; ri++){
                    output[currentWi][ci].add(null);
                }
            }
            
            // Iterate the rows
            for(Integer ri=0;ri<numberOfRowsInCurrentWorksheet; ri++){

                // Extracting the row reduces the CPU time by 50%, and for some weird reason improves the max heap size
                Dom.XmlNode row = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements()[ri];

                // Get the number of cells in the row
                Integer numberOfCells = row.getChildElements().size();

                // Iterate the cells
                for(Integer ci=0;ci<numberOfCells; ci++){

                    // Extracting the cell reduces the CPU time by another 50% !!
                    Dom.XmlNode cell = row.getChildElements()[ci];

                    String columnName = ParseUtil.columnNameFromCellName(cell.getAttributeValue('r', null));
                    String cellType   = cell.getAttributeValue('t', null);

                    // Define the value in case of an inline string or a shared string
                    Object value = (cellType == 'inlineStr') ?
                                    cell.getChildElement('is',Constant.NS_SPREADSHEET_ML)?.getChildElement('t', Constant.NS_SPREADSHEET_ML)?.getText() :
                                    cell.getChildElement('v', Constant.NS_SPREADSHEET_ML)?.getText()
                    ;

                    // Put the value inside
                    output[currentWi][ParseUtil.columnIndexMap.get(columnName)][ri] = (cellType == 's') ? sharedStrings[Integer.valueOf(value)] : value;   
                }
            }
        }

        // Return the sheets data as a multi dimensional array
        return output;
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries A map of path/zip entries from the unzipped XLSX file
     * @return      A list of sheets with a list of rows with a list of cell
     * @note        Use this method for the large sheets
     */
    global static Object[][][] toArrayInverted(Map<String,Compression.ZipEntry> entries){
        return toArrayInverted(entries, null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        Use this method for the large sheets
     */
    global static Object[][][] toArrayInverted(Map<String, Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create a multi-dimensional array for the output
        // Worksheet - Column - Row
        Object[][][] output = new Object[][][]{};

        // Create a list of shared strings
        String[] sharedStrings = getSharedStrings(entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of the largest number of columns. If one sheet is larger than the other
        // we do not do have a duplicate translation for overlapping column names
        // i.e. If sheet 1 has 10 columns and sheet 2 has 20 columns, make sure to only
        // translate the column names from 11 to 20 to save some CPU time
        Integer maxNumberOfColumnsInAllWorksheets = 0;

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi =0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Add array for the sheet to hold the columns and rows
            output.add(new Object[][]{});

            // Create an XSR for the current worksheet XML file
            XmlStreamReader xsr = new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', ''));

            // Set the current row to -1 so the indexes match
            Integer currentRi = -1;

            // Variables to hold the type and name of the current open cell element
            String cellType;
            String columnName;

            // Google sheets does not include the dimension attribute, so we need to 
            // figure out the dimensions in a different less efficient way
            Boolean hasDimensionAttribute = false;

            // Traverse the XML elements in the worksheet
            // I am not using while(xsr.hasNext()) to save a method call at the end of each item
            // For some reason it's about 30% faster to put an if statement at the end. No idea why.
            while(true) {

                // Start at the beginning of the book and make sure that it is a book
                if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                    switch on xsr.getLocalName() {

                        // First we need the dimension of the worksheet to find out the max size of our rows
                        // The order in the XML is mandatory, so this value should exist, if not the sheet is invalid
                        when 'dimension'{
                            
                            // Indicate we have a dimensions attribute
                            hasDimensionAttribute = true;

                            // Get the cell name from the range, the ref attribute is mandatory so should be there
                            // The ref value can be either in the format "A1:C3"
                            // or simply the intersecting cell only... i.e. "C3"
                            String cName = xsr.getAttributeValueAt(0)?.contains(':')     ? 
                                                xsr.getAttributeValueAt(0).split(':')[1] :
                                                xsr.getAttributeValueAt(0)
                            ;

                            // Safeguard: if the ref attribute is empty, ignore the dimension attribute
                            // and move on to manually calculate the number of rows
                            if(String.isBlank(cName) || cName?.toLowerCase() == Constant.DEF_SNGL_DIMENSION){
                                hasDimensionAttribute = false;
                            }

                            // Get the ref element from the token and calculate the value
                            String colName = ParseUtil.columnNameFromCellName(cName);

                            // Get the number of columns and rows that are in this worksheet
                            Integer numCols = CommonUtil.columnNumberFromColumnName(colName);
                            Integer numRows = Integer.valueOf(cName.removeStart(colName));

                            // Pre-populate a map with the column name related to the column index i.e. AA => 27, AB =>28 etc
                            // Prepopulating makes the parsing go a lot faster as we only have to calculate it once
                            if(numCols > maxNumberOfColumnsInAllWorksheets){

                                // Populate the column index (startnumber and the total number of columns)
                                ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numCols);

                                // Update to the new max column dimension
                                maxNumberOfColumnsInAllWorksheets = numCols;
                            }

                            // Add empty values for each (potential cell)
                            for(Integer ri=0; ri<numRows; ri++){

                                // Pre-populate the entire "grid" with empty lists and null values
                                output[currentWi].add(new Object[]{});

                                // Create a new entry for the row
                                for(Integer ci=0; ci<numCols; ci++){
                                    output[currentWi][ri].add(null);
                                }
                            }
                        }

                        // The first element after dimension where we can check
                        // only once that there is a dimension attribute
                        when 'sheetData'{
                            
                            // If we have no dimension attribute we'll have to figure out
                            // the last column. Until that fix just throw an exception
                            if(!hasDimensionAttribute){
                                ParseUtil.populateColumnIndexMapWithoutDimensionAttribute(
                                    new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', '')),
                                    currentWi,
                                    output,
                                    true // Inverted
                                );
                            }
                        }

                        // The row element, keep track of what row we're currently in
                        // We can have a situation where we have row 1 and 10 populated, but nothing in between
                        when 'row'{
                            currentRi = Integer.valueOf(xsr.getAttributeValue(null, 'r'))-1;
                        }

                        // The cell element
                        when 'c' {
                            columnName = ParseUtil.columnNameFromCellName(xsr.getAttributeValue(null, 'r'));
                            cellType   = xsr.getAttributeValue(null, 't');
                        }

                        // Value tags inside the cell element
                        when 'v','t'{

                            // Skip to the text element
                            xsr.next();

                            // Validate we're in a text element
                            if(xsr.getEventType() == XmlTag.CHARACTERS){
                                // Put the cell value in array at location wi.ci.ri
                                // If there is a "sharedStrings index", get the shared strings value at that index
                                // else the value in the value in the XSR
                                output[currentWi][currentRi][ParseUtil.columnIndexMap.get(columnName)] = (cellType == 's') ? sharedStrings[Integer.valueOf(xsr.getText())] : xsr.getText();
                            }
                        }
                    }
                }

                // If there is a next element go to the next element, else we're done
                if(xsr.hasNext()){ xsr.next(); } else { break; }
            }
        }

        // Return the sheets data as a multi dimensional array
        return output;
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a multi dimensional array in the form of
     *              data[WorksheetIndex][ColumnIndex][RowIndex]
     * @param  entries A map of path/zip entries from the unzipped XLSX file
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static Object[][][] toArrayInvertedDomDoc(Map<String,Compression.ZipEntry> entries){
        return toArrayInvertedDomDoc(entries, null);
    }


    /**
     * @description A method to parse the XML using the DOM.Document classes. There is a trade-off in the max size
     *              but this method is significantly faster on the CPU time.
     * @param entries        A map of path/zip entries from the unzipped XLSX file
     * @param selectedSheets A set of sheet indexes that are to be parsed
     * @return      A list of sheets with a list of rows with a list of cells
     * @note        I have optimized this method to being able to handle as much data as possible
     *              this meant that some data is in variable to achieve this. With magical results.
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static Object[][][] toArrayInvertedDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create a multi-dimensional array for the output
        // Worksheet - Column - Row
        Object[][][] output = new Object[][][]{};

        // Create a list of shared strings
        String[] sharedStrings = getSharedStrings(entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of the largest number of columns. If one sheet is larger than the other
        // we do not do have a duplicate translation for overlapping column names
        // i.e. If sheet 1 has 10 columns and sheet 2 has 20 columns, make sure to only
        // translate the column names from 11 to 20 to save some CPU time
        Integer maxNumberOfColumnsInAllWorksheets = 0;

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi=0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;
   
            // Add array for the sheet to hold the columns and rows
            output.add(new Object[][]{});

            // Create a DOM document for reading
            Dom.Document doc = new Dom.Document();

            // Load the XML
            doc.load(entries.get(worksheetPaths[wi]).getContent().toString());

            // Extract the dimension
            Dom.XmlNode dimension = doc.getRootElement().getChildElement('dimension', Constant.NS_SPREADSHEET_ML);

            // Get the number of columns / rows for this sheet
            Integer numberOfColumnsInCurrentWorksheet = 0;
            Integer numberOfRowsInCurrentWorksheet    = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements().size();

            // We know the number of rows, if there is no dimension element we need to figure out the largest
            // cell in any of the rows. To do this we read the last cell in each row and get the column number
            if(dimension == null || dimension != null && String.isBlank(dimension.getAttributeValue('ref', null))){
                for(Integer ri=0;ri<numberOfRowsInCurrentWorksheet; ri++){

                    // Extracting the row/cell reduces the CPU time by 50%, and for some weird reason improves the max heap size
                    Dom.XmlNode row  = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements()[ri];
                    Dom.XmlNode cell = row.getChildElements()[row.getChildElements().size()-1];

                    // Get the last column number
                    Integer lastColumnNumberInCurrentRow = CommonUtil.columnNumberFromColumnName(
                        ParseUtil.columnNameFromCellName(
                            cell.getAttributeValue('r', null)
                        )
                    );

                    // Update the largest column number in the worksheet if the one in the current row is the highest
                    if(numberOfColumnsInCurrentWorksheet < lastColumnNumberInCurrentRow){
                        numberOfColumnsInCurrentWorksheet = lastColumnNumberInCurrentRow;
                    }
                }

                // Populate the column index (startnumber and the total number of columns)
                // Keep track of the largest column number over all the worksheets
                if(numberOfColumnsInCurrentWorksheet > maxNumberOfColumnsInAllWorksheets){
                    ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numberOfColumnsInCurrentWorksheet);
                    maxNumberOfColumnsInAllWorksheets = numberOfColumnsInCurrentWorksheet;
                }
            }else{

                // Get the cell name from the range, the ref attribute is mandatory so should be there
                // The ref value can be either in the format "A1:C3"
                // or simply the intersecting cell only... i.e. "C3"
                String cName = dimension.getAttributeValue('ref', null) ?.contains(':')    ? 
                                    dimension.getAttributeValue('ref', null).split(':')[1] :
                                    dimension.getAttributeValue('ref', null)
                ;

                // Get the ref element from the token and calculate the value
                String colName = ParseUtil.columnNameFromCellName(cName);

                // Get the number of columns and rows that are in this worksheet
                numberOfColumnsInCurrentWorksheet = CommonUtil.columnNumberFromColumnName(colName);
                
                // Pre-populate a map with the column name related to the column index i.e. AA => 27, AB =>28 etc
                // Prepopulating makes the parsing go a lot faster as we only have to calculate it once
                if(numberOfColumnsInCurrentWorksheet > maxNumberOfColumnsInAllWorksheets){

                    // Populate the column index (startnumber and the total number of columns)
                    ParseUtil.populateColumnIndexMap(maxNumberOfColumnsInAllWorksheets, numberOfColumnsInCurrentWorksheet);

                    // Update to the new max column dimension
                    maxNumberOfColumnsInAllWorksheets = numberOfColumnsInCurrentWorksheet;
                }
            }

            // Add empty values for each (potential cell)
            for(Integer ri=0; ri<numberOfRowsInCurrentWorksheet; ri++){

                // Pre-populate the entire "grid" with empty lists and null values
                output[currentWi].add(new Object[]{});

                // Create a new entry for the row
                for(Integer ci=0; ci<numberOfColumnsInCurrentWorksheet; ci++){
                    output[currentWi][ri].add(null);
                }
            }
            
            // Iterate the rows
            for(Integer ri=0;ri<numberOfRowsInCurrentWorksheet; ri++){

                // Extracting the row reduces the CPU time by 50%, and for some weird reason improves the max heap size
                Dom.XmlNode row = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements()[ri];

                // Get the number of cells in the row
                Integer numberOfCells = row.getChildElements().size();

                // Iterate the cells
                for(Integer ci=0;ci<numberOfCells; ci++){

                    // Extracting the cell reduces the CPU time by another 50% !!
                    Dom.XmlNode cell = row.getChildElements()[ci];

                    String columnName = ParseUtil.columnNameFromCellName(cell.getAttributeValue('r', null));
                    String cellType   = cell.getAttributeValue('t', null);

                    // Define the value in case of an inline string or a shared string
                    Object value = (cellType == 'inlineStr') ?
                                    cell.getChildElement('is',Constant.NS_SPREADSHEET_ML)?.getChildElement('t', Constant.NS_SPREADSHEET_ML)?.getText() :
                                    cell.getChildElement('v', Constant.NS_SPREADSHEET_ML)?.getText()
                    ;

                    // Put the value inside
                    output[currentWi][ri][ParseUtil.columnIndexMap.get(columnName)] = (cellType == 's') ? sharedStrings[Integer.valueOf(value)] : value;
                }
            }
        }

        // Return the sheets data as a multi dimensional array
        return output;
    }


    /** **************************************************************************************************** **
     **                                          GLOBAL MAP METHODS                                          **
     ** **************************************************************************************************** **/
    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a list of maps where the cellName is
     *              used as the map key
     *              data[WorksheetIndex].get(cellName)
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @return      A list of Maps where each map represents a worksheet, each key the cellName
     *              and the map value the cell value
     */
    global static List<Map<String,Object>> toMap(Map<String,Compression.ZipEntry> entries){
        return toMap(entries, null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a list of maps where the cellName is
     *              used as the map key
     *              data[WorksheetIndex].get(cellName)
     * @param entries        A map of path/zip entries from the unzipped XLSX file
     * @param selectedSheets A set of sheet indexes that are to be parsed
     * @return      A list of Maps where each map represents a worksheet, each key the cellName
     *              and the map value the cell value
     */
    global static List<Map<String,Object>> toMap(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // List of maps to hold the output
        List<Map<String,Object>> output = new List<Map<String,Object>>();

        // Create a list of shared strings
        String[] sharedStrings  = getSharedStrings( entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi=0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Create a map for this worksheet
            output.add(new Map<String,Object>());

            // Create an XSR for the current worksheet XML file
            XmlStreamReader xsr = new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', ''));

            // Variables to hold the type and name of the current open cell element
            String cellName;
            String cellType;

            // Traverse the XML elements in the worksheet
            // I am not using while(xsr.hasNext()) to save a method call at the end of each item
            // For some reason it's about 30% faster to put an if statement at the end. No idea why.
            while(true) {

                // Start at the beginning of the book and make sure that it is a book
                if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                    switch on xsr.getLocalName() {

                        // The cell element
                        when 'c' {
                            cellName = xsr.getAttributeValue(null, 'r');
                            cellType = xsr.getAttributeValue(null, 't');
                        }

                        // Value tags inside the cell element
                        when 'v','t'{

                            // Skip to the text element
                            xsr.next();

                            // Validate we're in a text element
                            if(xsr.getEventType() == XmlTag.CHARACTERS){

                                // Put the value in wi.ri.ci, if shared strings get the shared strings value
                                // else the value in the value in the XSR
                                output[currentWi].put(
                                    cellName,
                                    (cellType == 's') ? sharedStrings[Integer.valueOf(xsr.getText())] : xsr.getText()
                                );
                            }
                        }
                    }
                }

                // If there is a next element go to the next element, else we're done
                if(xsr.hasNext()){ xsr.next(); }else{ break; }
            }
        }
        // Return the fully populated output
        return output;
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a list of maps where the cellName is
     *              used as the map key
     *              data[WorksheetIndex].get(cellName)
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes
     * @return      A list of Maps where each map represents a worksheet, each key the cellName
     *              and the map value the cell value
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static List<Map<String,Object>> toMapDomDoc(Map<String,Compression.ZipEntry> entries){
        return toMapDomDoc(entries,null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a list of maps where the cellName is
     *              used as the map key
     *              data[WorksheetIndex].get(cellName)
     * @param entries        A map of path/zip entries from the unzipped XLSX file
     * @param selectedSheets A set of sheet indexes that are to be parsed
     * @return      A list of Maps where each map represents a worksheet, each key the cellName
     *              and the map value the cell value
     * @note        Faster CPU time, but does not scale very well past 50k cells
     *              Use this method when you work with small sheets only
     */
    global static List<Map<String,Object>> toMapDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // List of maps to hold the output
        List<Map<String,Object>> output = new List<Map<String,Object>>();

        // Create a list of shared strings
        String[] sharedStrings  = getSharedStrings( entries);

        // In order to sort the worksheets, we need to to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in it's own array
        for(Integer wi=0, wiMax=worksheetPaths.size(); wi<wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Calculate the current worksheet index in case we select specific worksheets only
            Integer currentWi = wi-worksheetSkipCount;

            // Create a map for this worksheet
            output.add(new Map<String,Object>());

            // Create a DOM document for reading
            Dom.Document doc = new Dom.Document();

            // Load the XML
            doc.load(entries.get(worksheetPaths[wi]).getContent().toString());

            // Get the number of rows for this sheet
            Integer numberOfRows = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements().size();

            // Iterate the rows
            for(Integer ri=0;ri<numberOfRows; ri++){

                // Extracting the row reduces the CPU time by 50%, and for some weird reason improves the max heap size
                Dom.XmlNode row = doc.getRootElement().getChildElement('sheetData',Constant.NS_SPREADSHEET_ML).getChildElements()[ri];

                // Get the number of cells in the row
                Integer numberOfCells = row.getChildElements().size();

                // Iterate the cells
                for(Integer ci=0;ci<numberOfCells; ci++){

                    // Extracting the cell reduces the CPU time by another 50% !!
                    Dom.XmlNode cell = row.getChildElements()[ci];

                    // Get the cell name and the cell type
                    String cellName = cell.getAttributeValue('r', null);
                    String cellType = cell.getAttributeValue('t', null);

                    // Define the value in case of an inline string or a shared string
                    Object value = (cellType == 'inlineStr') ?
                                    cell.getChildElement('is',Constant.NS_SPREADSHEET_ML).getChildElement('t', Constant.NS_SPREADSHEET_ML).getText() :
                                    cell.getChildElement('v', Constant.NS_SPREADSHEET_ML).getText()
                    ;

                    // Put the value in wi.ri.ci, if shared strings get the shared strings value
                    // else the value in the value in the XSR
                    output[currentWi].put(
                        cellName,
                        (cellType == 's') ? sharedStrings[Integer.valueOf(value)] : value
                    );
                }
            }
        }
        // Return the fully populated output
        return output;
    }

    /** **************************************************************************************************** **
     **                                          GLOBAL SHEET MAP METHODS                                    **
     ** **************************************************************************************************** **/
    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a map of sheet name to 2D Object[][]
     *              (row-major order)
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @return                A map with the sheet name as key and the 2D Object[][] as value
     */
    global static Map<String, Object[][]> toSheetNameArrayMap(Map<String, Compression.ZipEntry> entries){
        return toSheetNameArrayMap(entries, null);
    }
    

    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a map of sheet name to 2D Object[][]
     *              (row-major order)
     * @author 
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes to parse
     * @return                A map with the sheet name as key and the 2D Object[][] as value
     */
    global static Map<String, Object[][]> toSheetNameArrayMap(Map<String, Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create the map for the output
        Map<String, Object[][]> sheetNameArrayMap = new Map<String, Object[][]>();

        // Get the sheet names related to the index
        Map<Integer,String> worksheetIndexNameMap = toWorksheetIndexNameMap(entries,selectedSheets);

        // Counter for the sheet index
        Integer wi = 0;
        
        // Populate the worksheets array
        for(Object[][] sheetData : toArray(entries,selectedSheets)){
            sheetNameArrayMap.put(worksheetIndexNameMap.get(wi),sheetData);
            wi++;
        }

        // Return the formatted data
        return sheetNameArrayMap;
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a map of sheet name to 2D Object[][]
     *              (column-major order) but putting it in a map using the sheet names
     * @author 
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @return                A map with the sheet name as key and the 2D Object[][] as value
     */
    global static Map<String, Object[][]> toSheetNameArrayInvertedMap(Map<String, Compression.ZipEntry> entries){
        return toSheetNameArrayInvertedMap(entries,null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data as a map of sheet name to 2D Object[][]
     *              (column-major order) but putting it in a map using the sheet names
     * @author 
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes to parse
     * @return                A map with the sheet name as key and the 2D Object[][] as value
     */
    global static Map<String, Object[][]> toSheetNameArrayInvertedMap(Map<String, Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Create the map for the output
        Map<String, Object[][]> sheetNameArrayMap = new Map<String, Object[][]>();

        // Get the sheet names related to the index
        Map<Integer,String> worksheetIndexNameMap = toWorksheetIndexNameMap(entries,selectedSheets);

        // Counter for the sheet index
        Integer wi = 0;
        
        // Populate the worksheets array
        for(Object[][] sheetData : toArrayInverted(entries,selectedSheets)){
            sheetNameArrayMap.put(worksheetIndexNameMap.get(wi),sheetData);
            wi++;
        }

        // Return the formatted data
        return sheetNameArrayMap;
    }

  
    /** **************************************************************************************************** **
     **                                        GLOBAL LLM TEXT METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a custom LLM optimised format that converts
     *              the sheets in column major order (i.e. as the sheet table)
     * @author 
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @return                An Custom LLM Text formatted representation of the data
     */
    global static String toLlmText(Map<String,Compression.ZipEntry> entries){
        return toLlmText(entries,null);
    }


    /**
     * @description Method that takes an unzipped xlsx archive as parameter and
     *              returns the sheet data in a custom LLM optimised format that converts
     *              the sheets in column major order (i.e. as the sheet table)
     * @author 
     * @param  entries        A map of path/zip entries from the unzipped XLSX file
     * @param  selectedSheets A set of integers representing the sheet indexes to parse
     * @return                An Custom LLM Text formatted representation of the data
     */
    global static String toLlmText(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets){

        // Output lines for the full workbook
        String[] output = new String[]{};

        // Create a list of shared strings
        String[] sharedStrings = getSharedStrings(entries);

        // In order to sort the worksheets, we need to put them in a list to sort
        String[] worksheetPaths = getWorksheetPaths(entries);

        // Get the names
        Map<Integer,String> worksheetIndexNameMap = toWorksheetIndexNameMap(entries, selectedSheets);

        // Keep track of skipped worksheets
        Integer worksheetSkipCount = 0;

        // Parse each worksheet in its own loop
        for(Integer wi = 0, wiMax = worksheetPaths.size(); wi < wiMax; wi++){

            // Skip sheets that are not included in the selectedSheets
            if(selectedSheets != null && !selectedSheets.contains(wi)){
                worksheetSkipCount++;
                continue;
            }

            // Add the sheet marker
            output.add(
                String.join(
                    new String[]{
                        'SHEET=',
                        worksheetIndexNameMap.get(wi-worksheetSkipCount)
                    },
                    ''
                )
            );

            // Create an XSR for the current worksheet XML file
            XmlStreamReader xsr = new XmlStreamReader(entries.get(worksheetPaths[wi]).getContent().toString().replace('\uFEFF', ''));

            // Variables to hold the type and name of the current open cell element
            String cellName;
            String cellType;

            // Keep track of current row state
            String[] currentRowParts = new String[]{};

            // Keep track of current column number
            Integer currentColumnNumber = null;

            Integer rowCounter    = -1;
            Integer columnCounter = -1;

            // Map that holds the caching between used column names i.e. A, AB, AAB etc. so its doesnt have to be calculated again
            Map<string,Integer> columnNameNumberMap = new Map<string,Integer>();

            // Traverse the XML elements in the worksheet
            while(true) {
                if (xsr.getEventType() == XmlTag.START_ELEMENT) {
                    switch on xsr.getLocalName() {

                        // The row element
                        when 'row' {
                            
                            // Increase the current row count (in case no r element exists)
                            rowCounter++;

                            // Reset the column counter for the current row (in case no r element exists)
                            columnCounter = -1;
                            
                            // Ignore when there is no row yet or the row has no cells in it
                            if(currentRowParts.size() > 1){
                                output.add(String.join(currentRowParts,'^'));
                            }
                            
                            // Add the current row token and the row number
                            currentRowParts = new String[]{ 'R' + (xsr.getAttributeValue(null, 'r') ?? rowCounter.toString()) };
                        }

                        // The cell element
                        when 'c' {
                            // Increment the column counter for the current row
                            columnCounter++;

                            // Extract cell attributes
                            cellName = xsr.getAttributeValue(null, 'r');
                            cellType = xsr.getAttributeValue(null, 't');

                            // If there is a cellname extract all the details, else just take the increment
                            if(cellName != null){
                                // Get the column name from the cell
                                String columnName = ParseUtil.columnNameFromCellName(cellName);

                                // Cache the column number based on the name
                                if(!columnNameNumberMap.containsKey(columnName)){
                                    columnNameNumberMap.put(columnName, CommonUtil.columnNumberFromColumnName(columnName));
                                }

                                // Set the current column number
                                currentColumnNumber = columnNameNumberMap.get(columnName);
                            }else{
                                currentColumnNumber = columnCounter;
                            }
                        }

                        // Value tags inside the cell element
                        when 'v','t' {

                            // Skip to the text element
                            xsr.next();

                            // Validate we're in a text element
                            if(xsr.getEventType() == XmlTag.CHARACTERS){

                                // Resolve the cell value
                                String cellValue = (cellType == 's')
                                    ? sharedStrings[Integer.valueOf(xsr.getText())]
                                    : xsr.getText()
                                ;

                                // Minimal normalization only, minimal performance impact
                                // Note this is not in a method because that slows things down again
                                // as its an addition function call for each cell
                                if(!String.isBlank(cellValue)){
                                    if(
                                        cellValue.contains('\r') ||
                                        cellValue.contains('\n') ||
                                        cellValue.contains('^')
                                    ){
                                        cellValue = cellValue.replace('\r', ' ');
                                        cellValue = cellValue.replace('\n', ' ');
                                        cellValue = cellValue.replace('^', ' ');
                                    }

                                    // Add the cell value part (works faster than string.join)
                                    currentRowParts.add('C' + currentColumnNumber + '=' + cellValue);
                                }
                            }
                        }
                    }
                }

                // If there is a next element go to the next element, else we're done
                if(xsr.hasNext()){
                    xsr.next();
                }else{
                    break;
                }
            }

            // Add the final row
            if(currentRowParts.size() > 1){
                output.add(String.join(currentRowParts, '^'));
            }
        }

        // Return the fully populated output text
        return String.join(output, '\n');
    }


    /** **************************************************************************************************** **
     **                              PRIVATE SUPPORT METHODS (CLASS SPECIFIC)                                **
     ** **************************************************************************************************** **/
    /**
     * @description This method takes a Map of file paths and returns an array of shared strings.
     * @param entries A Map of file paths.
     * @return      String[] An array of shared strings.
     */
    private static String[] getSharedStrings(Map<String,Compression.ZipEntry> entries){

        String[] sharedStrings = new String[]{};

        // Check the shared strings file exists
        if(entries.containsKey(Constant.ZP_PATH_SHRD_STRS)){

            // Create an XSR for the shared strings XML file
            XmlStreamReader xsr = new XmlStreamReader(entries.get(Constant.ZP_PATH_SHRD_STRS).getContent().toString().replace('\uFEFF', ''));
            
            // Treat texts as blocks
            xsr.setCoalescing(true);
            
            // Traverse the XML elements in the worksheet
            // I am not using while(xsr.hasNext()) to save a method call at the end of each item
            // For some reason it's about 30% faster to put an if statement at the end. No idea why.
            while(true){

                // Get all the string values and add them to the shared stings list
                if (xsr.getEventType() == XmlTag.START_ELEMENT && xsr.getLocalName() == 't') {
                    xsr.next();

                    // Add the value to the shared strings, if the tag is empty add a blank value
                    sharedStrings.add(xsr.getEventType() == XmlTag.CHARACTERS ? xsr.getText() : '');
                }

                // If there is a next element go to the next element, else we're done
                if(xsr.hasNext()){ xsr.next(); } else { break; }
            }
        }

        // Return the array of shared strings
        return sharedStrings;
    }


    /**
     * @description This method takes a Map of file paths and returns an array of worksheet paths.
     * @param entries A Map of file paths.
     * @return      String[] An array of worksheet paths.
    */
    private static String[] getWorksheetPaths(Map<String,Compression.ZipEntry> entries){

        // List to hold the worksheet paths
        String[] worksheetPaths = new String[]{};

        // Compile the pattern into a Regex object
        Pattern regex = Pattern.compile(Constant.WORKSHEET_PATH_REGEX);

        // Iterate through all the files in the workbook folder
        for(String path : entries.keySet()){
            if(regex.matcher(path).find()){
                worksheetPaths.add(path);
            }
        }
        // Sort the worksheet paths so they will be in the correct order
        worksheetPaths.sort();

        // Return the sort list of worksheet paths
        return worksheetPaths;
    }


    /** **************************************************************************************************** **
     **                                    PRIVATE DATA STRUCTURE CLASSES                                    **
     ** **************************************************************************************************** **/
    /**
     * @description Class representing a sheet index xml element
     *              Used to create a sortable list based on the index
     */
    private class SheetIndex implements Comparable{

        // Public variables
        private Integer index;
        private String  name;

        /**
         * @description Main constructor
         * @param index The sheet index
         * @param name  The sheet name
         */
        public SheetIndex(Integer index, String name){
            this.index = index;
            this.name  = name ;
        }

        /**
         * @description Method for comparable interface
         * @param compareTo The object to compare against
         * @return      1, 0 or -1
         */
        public Integer compareTo(Object compareTo){
            return (this.index > ((SheetIndex) compareTo).index) ? 1 : (this.index == ((SheetIndex) compareTo).index) ? 0 : -1;
        }
    }
}