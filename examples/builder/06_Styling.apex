/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example to show all different styling methods
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Configure the builder to use the shared strings index instead of inline strings
b.setUseSharedStrings(true);

// Set the file name
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_Styling_Examples.xlsx' );

// Set the file properties
b.setTitle('Styling Examples (' + xlsx.CommonUtil.getTimestampString() + ')');
b.setSubject('Styling');
b.setDescription('Example implementation of all supported styling options');
b.addKeyword('Style');
b.addKeyword('Styles');

/**
 * Every cell style is composed of a number of individual, reusable components.
 * Each of these components have an index. You create styles by mixing and matching
 * the different components to create unique combinations.
 * This can be a lot of code unfortunately, but I could not find an easy way to do this.
 */
// Create number format (Id, Format Code), Not that the
Integer numberFormatId = xlsx.StylesBuilder.addNumberFormat(b, 166, '"$"#,##0.00');

// Create alignment (Builder, horizontal,  vertical, textRotation, wrapText)
Integer alignmentIndex = xlsx.StylesBuilder.addAlignment(b, 'center', 'center', 0 , true);

// Create fonts (Builder, Size, Name, Color, Bold, Italic, Underline)
Integer fontIndex      = xlsx.StylesBuilder.addFont(b, 12, 'Consolas', '242424', true, true, true);

// Create fills (Builder, patternType, foreground color, background color)
Integer fillIndex      = xlsx.StylesBuilder.addFill(b, 'lightGray', 'FE8F7D', 'FE5C4C');
Integer rowfillIndex   = xlsx.StylesBuilder.addFill(b, 'solid',     'DEF9F3', null);
Integer colfillIndex   = xlsx.StylesBuilder.addFill(b, 'solid',     'F9F0FF', null);

// Add a border (builder, left, right, top, bottom)
// Add a borderConfig (type, color)
Integer borderIndex    = xlsx.StylesBuilder.addBorder(
    b,
    xlsx.StylesBuilder.borderConfig('dotted', 'FF0000'),
    xlsx.StylesBuilder.borderConfig('thick',  '00FF00'), 
    xlsx.StylesBuilder.borderConfig('thin',   '0000FF'), 
    xlsx.StylesBuilder.borderConfig('medium', '00FFFF')
);

// Create Style indexes (Builder, NumberFormat ID, Font Index, Fill Index, Border Index)
Integer cellStyleIndex = xlsx.StylesBuilder.addCellStyle(b, numberFormatId, fontIndex, fillIndex, borderIndex, alignmentIndex);

// Create a style for a full row
Integer rowStyleIndex  = xlsx.StylesBuilder.addCellStyle(b, null, fontIndex, rowfillIndex, 0, null);

// Create a style for a full row
Integer colStyleIndex  = xlsx.StylesBuilder.addCellStyle(b, null, 0,         colfillIndex, 0, null);

// Create cell
b.addNumberCell(0, 1, 1, 123.45);

// Apply the cell styling
b.setCellStyle(0, 1, 1, cellStyleIndex);

// Create second cell with style overload method
b.addNumberCell(0, 3, 1, 123.45, cellStyleIndex);

// Make the cell nice and big
b.setColWidth( 0, 1, 25);

// Make the cell nice and big
b.setColStyle( 0, 1, colStyleIndex);

// Set the style for a column (worksheet index, column index, style index)
b.setRowStyle(0, 1, rowStyleIndex);

// Set the height for a row (worksheet index, row index, points)
b.setRowHeight(0, 1, 50);

// Set the style for a row (worksheet index, row index, style index)
b.setRowStyle(0, 1, rowStyleIndex);

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