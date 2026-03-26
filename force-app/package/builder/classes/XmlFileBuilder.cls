/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds the methods to create the individual
 * *               XML files by combining the Xml Element Class instances
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 */
@SuppressWarnings('PMD.OneDeclarationPerLine')
public with sharing class XmlFileBuilder {

    /** **************************************************************************************************** **
     **                                     XML FILE GENERATION METHODS                                      **
     ** **************************************************************************************************** **/
     /**
     * @description Method to get the "xl/sharedStrings.xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "xl/sharedStrings.xml" file body
     */
    public static XmlFile getSharedStringsXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_XL,
            Constant.FILE_SHRD_STRS,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.sharedStrings
            ))
        );
    }


    /**
     * @description Method to get the "xl/styles.xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "xl/styles.xml" file body
     */
    public static XmlFile getStylesXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_XL,
            Constant.FILE_STYLES,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.styleSheet
            ))
        );
    }


    /**
     * @description Method to get the "xl/workbook.xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "xl/workbook.xml" file body
     */
    public static XmlFile getWorkbookXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_XL,
            Constant.FILE_WORKBOOK,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.workbook
            ))
        );
    }


    /**
     * @description Method to get the "docProps/core.xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "docProps/core.xml" file body
     */
    public static XmlFile getCoreXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_DOC_PROPS,
            Constant.FILE_CORE,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.coreProperties
            ))
        );
    }


    /**
     * @description Method to get the "docProps/app.xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "docProps/app.xml" file body
     */
    public static XmlFile getAppXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_DOC_PROPS,
            Constant.FILE_APP,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.properties
            ))
        );
    }


    /**
     * @description Method to get the "xl/worksheets/sheetX.xml" XML Body
     *              This uses a sheet index to preserve heap space. It stops you from having
     *              to store any sheet data in a variable. Not the cleanest solution but the
     *              most heap efficient.
     * @param b     The Builder class instance
     * @param wi    The worksheet index (zero based)
     * @return      The Xml File containing the "xl/worksheets/sheetX.xml" XML file body
     */
    public static XmlFile getWorksheetXmlFile(Builder b, Integer wi){
        return new XmlFile(
            Constant.FOLDER_XL_WORKSHEET,
            String.format(
                Constant.FILE_SHEET,
                new String[]{wi.toString()}
            ),
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.worksheets[wi]
            ))
        );
    }


    /**
     * @description Method to get the "[Content_Types].xml" XML Body
     * @param b     The Builder class instance
     * @return      The XmlFile containing the "[Content_Types].xml" file body
     */
    public static XmlFile getContentTypesXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_BLANK,
            Constant.FILE_CONTENT_TYPES,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.contentTypes
            ))
        );
    }


    /**
     * @description Method to get the "_rels/.rels" XML Body
     * @param b     The Builder class instance
     * @return      The Xml File containing the "_rels/.rels" file body
     */
    public static XmlFile getRelsXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_RELS,
            Constant.FILE_RELS,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.relationships
            ))
        );
    }


    /**
     * @description Method to get the "xl/_rels/workbook.xml.rels" XML Body
     * @param b     The Builder class instance
     * @return      The Xml File containing the "xl/_rels/workbook.xml.rels" file body
     */
    public static XmlFile getWorkbookRelsXmlFile(Builder b){
        return new XmlFile(
            Constant.FOLDER_XL_RELS,
            Constant.FILE_WORKBOOK_RELS,
            Blob.valueof(writeTopLevelXmlElementXmlString(
                b.workbookRelationships
            ))
        );
    }


    /** **************************************************************************************************** **
     **                                       PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method that writes the TOP LEVEL XmlElement to an XML String
     * @param xe    A top level XML element
     * @return      XML string representation of the the inputted IXmlElement
     */
    private static String writeTopLevelXmlElementXmlString(IXmlElement xe){

        // Create the new XmlStreamWriter
        XmlStreamWriter x = new XmlStreamWriter();

        // Write the start of the document
        x.writeStartDocument(Constant.ENCODING, Constant.VERSION);

        // Write the top level Xml Element
        xe.writeXml(x);

        // Close any start tags
        x.writeEndDocument();

        // Return the XML String
        return x.getXmlString();
    }
}