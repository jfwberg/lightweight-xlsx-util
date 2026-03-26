/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class containing utilities for the Parsing of XLSX files
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 */
public with sharing class ParseUtil {

    // Map that holds the column name as a key and it's matching index as a value
    // This is for optimizing performance by caching instead of repeat calculation
    public static Map<String,Integer> columnIndexMap = new Map<String,Integer>();

    /**
     * @description Method to populate the column index map with the starting index and number of columns
     * @param  startIndex      The starting index of the column
     * @param  numberOfColumns The number of columns to be added to the map
     */
    public static void populateColumnIndexMap(Integer startIndex, Integer numberOfColumns){
        for(Integer i=startIndex;i<numberOfColumns;i++){
            columnIndexMap.put(CommonUtil.columnNameFromColumnIndex(i),i);
        }
    }


    /**
     * @description Method to get the letter part of an input cellName i.e. ALL100 returns ALL
     * @param  cellName The cell name to extract the column letter from
     * @return          The column letter in the form of a string
     */
    public static String columnNameFromCellName(String cellName){
        Matcher m = Constant.CELL_NAME_PATTERN.matcher(cellName);
        if(!m.find()){
            throw new ParseException(String.format(Constant.MSG_INVALID_CELL_NAME, new String[]{cellName}));
        }
        return m.group(1);
    }


    /**
     * @description Method to get the last row and the last cell to create our own dimensions
     *              in case of a missing dimension XML element
     * @note        The use of this method with an additional stream reader makes it very slow.
     *              Ideally you should always have the dimention element of the sheet.
     * @param  xsr       The XML stream reader for the current worksheet
     * @param  currentWi The current worksheet index
     * @param  output    The output array to pre-populate
     * @param  inverted  Boolean to indicate if the output should be inverted
     */
    @SuppressWarnings('PMD.OneDeclarationPerLine, PMD.CognitiveComplexity')
    public static void populateColumnIndexMapWithoutDimensionAttribute(XmlStreamReader xsr, Integer currentWi, Object[][][] output, Boolean inverted){

        String   lastRowRAttribute;
        String   lastCellRAttribute;
        String[] lastCellRAttributes = new String[]{};
        Integer  maxColumnNumber = 0;

        while (true) {
            switch on xsr.getEventType() {
                when START_ELEMENT {
                    switch on xsr.getLocalName() {
                        when  'row'{
                            lastRowRAttribute = xsr.getAttributeValue(null,'r');
                        }
                        when 'c' {
                            lastCellRAttribute = xsr.getAttributeValue(null,'r');
                        }
                    }
                }
                when END_ELEMENT {
                    switch on xsr.getLocalName() {
                        when 'row'{
                            lastCellRAttributes.add(lastCellRAttribute);
                        }
                    }
                }
            }

            // Check if there is next element and break otherwise
            if (xsr.hasNext()) {xsr.next();} else {break;}
        }

        for(Integer i=0,max=lastCellRAttributes.size(); i<max;i++ ){
            Integer columnNumber = CommonUtil.columnNumberFromColumnName(columnNameFromCellName(lastCellRAttributes[i]));
            if(maxColumnNumber < columnNumber){
                maxColumnNumber = columnNumber;
            }
        }

        // Populate the column indexes based on the biggest cell
        populateColumnIndexMap(0,maxColumnNumber);

        // Convert he last number of rows
        Integer numberOfRows = Integer.valueOf(lastRowRAttribute);

        // For inverted methods swap the columns and rows around
        if(inverted){
            // Add empty values for each (potential cell)
            for(Integer ri=0; ri<numberOfRows; ri++){

                // Pre-populate the entire "grid" with empty lists and null values
                output[currentWi].add(new Object[]{});

                // Create a new entry for the row
                for(Integer ci=0; ci<maxColumnNumber; ci++){
                    output[currentWi][ri].add(null);
                }
            }
        }else{
            // Add empty values for each (potential cell)
            for(Integer ci=0; ci<maxColumnNumber; ci++){

                // Pre-populate the entire "grid" with empty lists and null values
                output[currentWi].add(new Object[]{});

                // Create a new entry for the row
                for(Integer ri=0; ri<numberOfRows; ri++){
                    output[currentWi][ci].add(null);
                }
            }
        }
    }
}