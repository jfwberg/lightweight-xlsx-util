/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    This is an example on how to create hyperlinks between sheets
 *                 These examples are very verbose for learning purposes
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_hyperlinks.xlsx' );

// Create example worksheets
Integer wsi0 = b.addWorksheet('Index Sheet');
Integer wsi1 = b.addWorksheet('Worksheet 01');
Integer wsi2 = b.addWorksheet('Worksheet 02');
Integer wsi3 = b.addWorksheet('Worksheet 03');

// Give our tab a festive color (random color)
b.setTabColor(wsi0,xlsx.CommonUtil.randomHtmlHexColorCode());
b.setTabColor(wsi1,xlsx.CommonUtil.randomHtmlHexColorCode());
b.setTabColor(wsi2,xlsx.CommonUtil.randomHtmlHexColorCode());
b.setTabColor(wsi3,xlsx.CommonUtil.randomHtmlHexColorCode());

// Add rows with a single cell to the first sheet
b.addTextCell(wsi0, 0, 0, 'Worksheet 00 - A1');
b.addTextCell(wsi0, 0, 1, 'Worksheet 00 - B2');
b.addTextCell(wsi0, 0, 2, 'Worksheet 00 - C3');

// Add the back to Index hyper links
b.addTextCell(wsi1, 0, 0, 'Back to Index');
b.addTextCell(wsi2, 0, 0, 'Back to Index');
b.addTextCell(wsi3, 0, 0, 'Back to Index');


/**
 * Verbose output to show how a hyperlink works over multiple sheets
 */
// Get the target cell A1 ([0][0])
String ws1TargetCell = xlsx.CommonUtil.cellName(0,0);

// The Completed target worksheet + the cell in that worksheet format looks like this: 'Worksheet 01'!A1
String ws1A1Hyperlink = '\'Worksheet 01\'!' + ws1TargetCell;

// Add hyperlinks (Worksheet index, Column Index, RowIndex, location/target, display value)
// Note the the display value does not do anything due to how single string are implemented, but this is future proofing
b.addHyperlink(0, 0, 0, ws1A1Hyperlink,	'Worksheet 01 - A1');


// Get the target cell B2 ([1][1])
String ws2TargetCell = xlsx.CommonUtil.cellName(1,1);

// The Completed target worksheet + the cell in that worksheet format looks like this: 'Worksheet 01'!A1
String ws2B2Hyperlink = '\'Worksheet 02\'!' + ws2TargetCell;

// Add hyperlinks (Worksheet index, Column Index, RowIndex, location/target, display value)
b.addHyperlink(0, 0, 1, ws2B2Hyperlink,	'Worksheet 02 - B2');


// Get the target cell C3 ([2][2])
String ws3TargetCell = xlsx.CommonUtil.cellName(2,2);

// The Completed target worksheet + the cell in that worksheet format looks like this: 'Worksheet 01'!A1
String ws3C3Hyperlink = '\'Worksheet 03\'!' + ws3TargetCell;

// Add hyperlinks (Worksheet index, Column Index, RowIndex, location/target, display value)
b.addHyperlink(0, 0, 2, ws3C3Hyperlink,	'Worksheet 03 - C3');


// Get the target cell A1 ([0][0])
String ws0TargetCell = xlsx.CommonUtil.cellName(0,0);

// The Completed target worksheet + the cell in that worksheet format looks like this: 'Worksheet 01'!A1
String ws0A1Hyperlink = '\'Index Sheet\'!' + ws0TargetCell;

// Add links back to the Index Sheet
b.addHyperlink(wsi1, 0, 0, ws0A1Hyperlink,	'Back to Index');
b.addHyperlink(wsi2, 0, 0, ws0A1Hyperlink,	'Back to Index');
b.addHyperlink(wsi3, 0, 0, ws0A1Hyperlink,	'Back to Index');

// Build the workbook as a document, insert it and get the link
System.debug(
    insertDocumentAndGetDownloadLink(
        xlsx.Build.asDocument(b)
    )
);


/** **************************************************************************************************** **
 **                                       PRIVATE SUPPORT METHODS                                        **
 ** **************************************************************************************************** **/
/**
 * @description Method to insert a Document and retrieve its download link
 * @param  d The Document to be inserted
 * @return   The download link for the inserted Document
 */
private static String insertDocumentAndGetDownloadLink(Document d){
    insert as user d;
    return URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + d.Id;
}