/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class containing support methods for the build process
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 * @false-positive ExcessiveParameterList   I need to find a nicer way for the massive amount of parameters.
 *                                          Unfortunately there are many of them and this is the easiest for now.
 */
@SuppressWarnings('PMD.OneDeclarationPerLine, PMD.ExcessiveParameterList')
public with sharing class BuildUtil {

    // Add counters to prevent adding the same name multiple times
    private static Integer columnNamesSize = 0;
    private static Integer rowNamesSize    = 0;
    
    // Variables to hold column and row names during file creation
    // Used to create cell names like A1 B2, ADD100 etc.
    // Referencing is quicker than multiple times of adding number and string concatenation
    public static String[] columnNames = new String[]{};
    public static String[] rowNames    = new String[]{};
    

    /**
     * @description Method to populate the array with column and row names
     *              Using a list reference is faster than repeatedly calculating the row names
     *              This gains performance when having lots of worksheets
     * @param numberOfColumns Number of columns to pre-populate
     * @param numberOfRows    Number of rows to pre-populate
     */
    public static void populateColumnAndRowNames(Integer numberOfColumns, Integer numberOfRows){
        
        // Populate column names
        for(Integer i=columnNamesSize; i<=numberOfColumns; i++){
            columnNames.add(CommonUtil.columnNameFromColumnIndex(i));
            columnNamesSize++;
        }

        // Populate row names
        for(Integer i=rowNamesSize; i<=numberOfRows; i++){
            rowNames.add((i+1).toString());
            rowNamesSize++;
        }
    }


    /**
     * @description Method to convert a cell and row index to a cell name
     *              i.e. 0.0 is A1, 1,1 = B2 etc.
     * @param ci The column index
     * @param ri The row index
     * @return      A cell name string
     * @note        Needs to run after the populateColumnAndRowNames() method has run
     */
    public static String getCellName(Integer ci, Integer ri){
        return columnNames[ci]+rowNames[ri];
    }


    /**
     * @description Method to generate a row index based on the start and end index
     *              i.e 0.0.1.1 becomes A1:B2
     * @param startCi The start column index
     * @param startRi The start row index
     * @param endCi   The end column index
     * @param endRi   The end row index
     * @return      A cell range string
     * @note        Needs to run after the populateColumnAndRowNames() method has run
     */
    public static String getCellRange(Integer startCi, Integer startRi, Integer endCi, Integer endRi){
        return columnNames[startCi]+rowNames[startRi] + ':' + columnNames[endCi]+rowNames[endRi];
    }


    /**
     * @description Method to make writing single XML elements with characters a bit easier
     * @param x         The XmlStreamWriter
     * @param ns        The namespace
     * @param element   The element name
     * @param value     The element value
     */
    public static void writeSingleXmlElement(XmlStreamWriter x, String ns, String element, String value){
        x.writeStartElement(ns, element, ns == null ? null : '');
        x.writeCharacters(value);
        x.writeEndElement();
    }


    /**
     * @description Method to make writing a single XML element with a single child list a bit easier
     * @param x             The XmlStreamWriter
     * @param ns            The namespace
     * @param element       The element name
     * @param childElements The child elements
     */
    public static void writeSingleXmlElementWithChildren(XmlStreamWriter x, String ns, String element, IXmlElement[] childElements){

        // Validate the XML element needs to be written
        if(childElements?.isEmpty() ?? true){
            return;
        }

        // We don't want to write the parent tag if all child elements are null
        Boolean hasNonNullChildElements = false;

        // Check if all child elements are null, as soon as a non-null element has been found in the list
        // break the cycle and set the tot true
        for(Integer i=0,max=childElements.size(); i<max;i++){
            if(childElements[i] != null){
                hasNonNullChildElements = true;
                break;
            }
        }

        // Only write the parent element and child elements if there is one that is not null
        // Make the namespace url an empty string when the namespace is not blank
        if(hasNonNullChildElements){
            x.writeStartElement(ns, element, ns == null ? null : '');
            for(Integer i=0,max=childElements.size(); i<max;i++){
                if(childElements[i] != null){
                    childElements[i].writeXml(x);
                }
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Method to make writing a single XML element with a single child list a bit easier
     * @param x             The XmlStreamWriter
     * @param ns            The namespace
     * @param element       The element name
     * @param childElements The child elements
     * @param dns           The default namespace
     */
    public static void writeSingleXmlElementWithChildrenAndDefaultNamespace(XmlStreamWriter x, String ns, String element, IXmlElement[] childElements, String dns){

        // Validate the XML element needs to be written
        if(childElements?.isEmpty() ?? true){
            return;
        }

        // Write the element and child elements
        // Make the namespace url an empty string when the namespace is not blank
        x.writeStartElement(ns, element, ns == null ? null : '');

        // Write the default namespace
        x.writeDefaultNamespace(dns);

        // Write the child elements
        for(Integer i=0,max=childElements.size(); i<max;i++){
            childElements[i].writeXml(x);
        }
        x.writeEndElement();
    }


    /**
     * @description Method to remove any extension from the file name that is not Constant.FULL_FILE_EXTENSION
     *              and adds the extension if it is not present
     * @param fileName The file name to sanitize
     * @return      The sanitized file name
     */
    public static String getSanitizedFileName(String fileName){
        if(fileName.contains('.') && !fileName.endsWith(Constant.FULL_FILE_EXTENSION)){
            return fileName.substringBefore('.') + Constant.FULL_FILE_EXTENSION;
        }else if(!fileName.endsWith(Constant.FULL_FILE_EXTENSION)){
            return fileName += Constant.FULL_FILE_EXTENSION;
        }
        return fileName;
    }


    /**
     * @description Method to sanitize the worksheet name
     * @param name  The worksheet name to sanitize
     * @return      The sanitized worksheet name
     */
    public static String sanitizeWorksheetName(String name){

        // Validate length and emptiness
        if(String.isBlank(name) || (String.isNotBlank(name) && name.length() > 31)){
            throw new BuildException(Constant.MSG_INVALID_WS_NAME);
        }

        // Strip out the bad characters (\,/,?,*,[ and ])
        name = name.replaceAll(Constant.WS_NAME_REGEX,'');

        // Strip out illegal characters and if the name has only illegal characters generate a random name
        return (name.length() > 0) ? name : String.format(Constant.INVALID_SHEET_TITLE, new String[]{CommonUtil.randomHtmlHexColorCode()});
    }


    /**
     * @description Method that returns the largest integer from a list
     *              will return 0 if the input list is empty
     * @param input The list of integers
     * @return      The largest integer
     */
    public static Integer getMaxIntegerFromList(Integer[] input){

        // Return 0 if the input list is null or empty
        if(input?.isEmpty() ?? true){
            return 0;
        }

        // If the array is greated than 0, it will be at least size 1, so start our first max number is the index 0
        Integer max = input[0];

        // Check if the next number is larger than the current
        for(Integer i=1, imax=input.size(); i<imax; i++){
            if(input[i] > max){
                max = input[i];
            }
        }

        // Simply return the maximum number
        return max;
    }
}