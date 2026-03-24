/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds a set of common utilities that a developer can use
 *                 when creating XLSX files that are slightly more complex
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.OneDeclarationPerLine')
global with sharing class CommonUtil {


    /**
     * @description Method to convert column index to column name
     * @note        Ported from geeksforgeeks.org example
     *              https://www.geeksforgeeks.org/find-excel-column-name-given-number/
     * @note        The input is the zero index from an array, not the column number
     * @param  columnIndex The zero index of the column
     * @return             The name of the column
     */
    global static String columnNameFromColumnIndex(Integer columnIndex){

        // Convert the column index to a number for the calculations
        Integer columnNumber = columnIndex +1;

        // Name of the column
        String columnName = '';

        // When less than 26 just return the letter
        if(columnNumber < 26 ){
            return columnName = Constant.CHARS[columnNumber - 1];
        }

        // As long as we have a remainder continue
        while (columnNumber > 0) {

            // Find remainder
            Integer rem = Math.mod(columnNumber,26);

            // No remainder means its 26, so it's Z
            if (rem == 0) {
                columnName  +=('Z');
                columnNumber = (columnNumber / 26) - 1;
            }else{
                columnName  += Constant.CHARS[rem - 1] ;
                columnNumber = columnNumber / 26;
            }
        }
        return columnName.reverse();
    }


    /**
     * @description Method that returns the number index for a column i.e. A = 1, B=2, ALL=1000
     * @note        This method uses the number, not the zero index
     * @note        Ported from geeksforkeeks.org example
     *              https://www.geeksforgeeks.org/find-excel-column-number-column-title/
     * @param columnName The name of the column i.e. A,B,ALL
     * @return      The number representation of the column i.e. 1,2,1000
     */
    global static Integer columnNumberFromColumnName(String columnName){

        // Split the column name so we can iterate each character
        String[] columnNameIndex = columnName.split('');

        // Start the result counter
        Integer result = 0;

        // Iterate each letter of the column name and multiply accordingly
        for (Integer i = 0, max = columnNameIndex.size(); i < max; i++){
            result *= 26;
            result += Constant.NUMS.get(columnNameIndex[i]);
        }
        return result;
    }


    /**
     * @description Method to convert column number and row number to cell name
     * @param  columnIndex The index of the column
     * @param  rowIndex    The index of the row
     * @return             The name of the cell
     */
    global static String cellName(Integer columnIndex, Integer rowIndex){
        return columnNameFromColumnIndex(columnIndex)+(rowIndex+1);
    }


    /**
     * @description Method to generate a random HTML HEX Color that can be used
     *              to style tabs during testing. When you have open a lot of excel files
     *              it's * to actually see you have a different document open.
     * @return      A random HTML HEX Color code
     */
    global static String randomHtmlHexColorCode(){
        return UUID.randomUUID().toString().substring(24,30);
    }


    /**
     * @description Method to get the current timestamp used in the builder
     * @return      The current timestamp used in the Builder class
     */
    global static Datetime getTimestamp(){
        return Constant.NOW;
    }


    /**
     * @description Method to get the current timestamp used in the builder as a string
     *              that can be used in file names or logs.
     * @return      The current timestamp used in the Builder class as a string
     */
    global static String getTimestampString(){
        return Constant.NOW.format(Constant.TIMESTAMP_FORMAT);
    }


    /** **************************************************************************************************** **
     **                                     GLOBAL TEST UTILITY METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method to get a text body from a static resource
     *              Ideal if you have stored cert data (temporarily) in a static resource or during
     *              apex tests
     * @param       staticResourceName   The developer name of the static resource you want the body
     *                                   value from
     * @return      Static resource body
     * @throws      InvalidDataException There is an issue with the static resource
     */
    global static String getStaticResourceBody(String staticResourceName){
        try{
            return ([SELECT Body FROM StaticResource WHERE Name = :staticResourceName WITH USER_MODE LIMIT 1]?.Body)?.toString();
        }catch(System.QueryException e){
            throw new InvalidDataException(String.format(Constant.MSG_STATIC_RESOURCE_ERROR, new String[]{staticResourceName}));
        }
    }


    /** **************************************************************************************************** **
     **                                      GLOBAL EXCEPTION CLASSES                                        **
     ** **************************************************************************************************** **/
    /**
     * @description An exception that is thrown when something goes wrong retrieving
     *              any (meta) data
     * @note        This class is private and test visible as it should only be ever caught
     *              when an Apex Unit Test is running and never from normal code
     */
    global with sharing class InvalidDataException extends Exception{}

}