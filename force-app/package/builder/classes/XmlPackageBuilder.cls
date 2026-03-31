/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds methods to build the Xml xmlPackage
 */
 public with sharing class XmlPackageBuilder {

    /**
     * @description Method to get all the required XML files and combine them
     *              into a zip file
     * @param b     The xlsx.Builder class instance to build
     * @return      The Blob body of a zipped XLSX file
     */
    public static Blob getPackage(Builder b){

        // First we need to determine the maximum number of columns so we can create a column array
        // Creating the column array once saves a lot of CPU Time
        // Creating a constant is even faster, but not dynamic. I choose the trade-off to make it dynamic
        // to have the best of both worlds.
        // The same applies for rows, really interesting, apparently a adding 1 to a number and
        // concatenate a string takes more cpu time than doing it once and referencing the String value from
        // a list ever after i.e. [0] = '1', [1] = '2' etc. Saves a lot of time when repeated
        //
        // If there are more columns than rows, use the columns value. This is so pane sizes won't go out of bounds
        // I have abused the array for basically all row column and row related namings. So row name is not really accurate.

        // Extract the highest indexes
        Integer maxWorksheetIndex = b.getMaxWorksheetIndex() + Constant.WS_RID_OFFSET;
        Integer maxColumnIndex    = b.getMaxColumnIndex();
        Integer maxRowIndex       = b.getMaxRowIndex() ;

        // Set the max index to a higher number if either the number of columns or worksheets is higher than the number of rows
        maxRowIndex = (maxColumnIndex    > maxRowIndex) ? maxColumnIndex    : maxRowIndex;
        maxRowIndex = (maxWorksheetIndex > maxRowIndex) ? maxWorksheetIndex : maxRowIndex;

        // Create the array
        BuildUtil.populateColumnAndRowNames(
            maxColumnIndex,
            maxRowIndex
        );

        // Create a new zip writer instance tp gemerat
        Compression.ZipWriter xmlPackage = new Compression.ZipWriter();

        // Add styles ("xl/sharedStrings.xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getSharedStringsXmlFile(b));

        // Add styles ("xl/styles.xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getStylesXmlFile(b));

        // Add the core properties ("docProps/core.xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getCoreXmlFile(b));

        // Add extended properties ("docProps/app.xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getAppXmlFile(b));

        // Add workbook file ("xl/workbook.xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getWorkbookXmlFile(b));

        // Add worksheet file with all the worksheets ("xl/worksheets/sheetX.xml")
        for(Integer i=0; i<=b.getMaxWorksheetIndex(); i++){
            addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getWorksheetXmlFile(b,i));
        }

        // Add content types ("[Content_Types].xml")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getContentTypesXmlFile(b));

        // Add _rels file ("_rels/.rels")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getRelsXmlFile(b));

        // Add workbook rels ("xl/_rels/workbook.xml.rels")
        addXmlFileToXmlPackage(xmlPackage, XmlFileBuilder.getWorkbookRelsXmlFile(b));

        // Return the full zip archive
        return xmlPackage.getArchive();
    }


    /** **************************************************************************************************** **
     **                                       PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description   Method to add an XML file to a zip file
     *                This method is used to preserve heap space by not storing the Xml File in a variable
     * @param zw      The zip writer instance to add the file to add the Xml File to
     * @param xmlFile The XML file to add to the Zip File
     */
    private static void addXmlFileToXmlPackage(Compression.ZipWriter zw, XmlFile xmlFile){
        zw.addEntry(
            String.format(
                '{0}{1}',
                new String[]{
                    (String.isNotBlank(xmlFile.folder) ? xmlFile.folder : ''),
                    xmlFile.fileName
                }
            ),
            xmlFile.fileBody
        );
    }
}