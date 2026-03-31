/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    An example to get sObject dependencies and their loading order for
 *                 all sObjects that contain data
 * 
 * @note           REQUIRES SortUtil and SortSObjectsWithData classes to be in the org
 * 
 * - https://medium.com/@justusvandenberg/programmatically-determine-the-object-loading-order-for-salesforce-data-migrations-using-apex-1f65841531fb
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_Data_Migration_Guide_Example.xlsx' );

// Set file properties
b.setTitle('Data Migration Guide Example (' + xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('Data Migration');
b.setDescription('An example of how you parse the result of sObject dependencies directly to an XLSX file');

// Make it look fancy by adding the default styles
b.setIncludeDefaultStyles(true);

// Main worksheet index
Integer wi0 = b.addWorksheet('sObjects');
Integer wi1 = b.addWorksheet('Warnings');

// Set the default row index to 0 for the headers
Integer ri0 = 0;
Integer ri1 = 0;

// Create header columns
b.addTextCell(wi0, 0, ri0, 'Loading Order',      xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 4));
b.addTextCell(wi0, 1, ri0, 'sObject Name',       xlsx.StylesBuilder.getHeaderStyleIndex(1, 0, 4));
b.addTextCell(wi0, 2, ri0, 'Depth',              xlsx.StylesBuilder.getHeaderStyleIndex(2, 0, 4));
b.addTextCell(wi0, 3, ri0, 'Relationship Path',  xlsx.StylesBuilder.getHeaderStyleIndex(3, 0, 4));
b.addTextCell(wi0, 4, ri0, 'Number of warnigns', xlsx.StylesBuilder.getHeaderStyleIndex(3, 0, 4));

// Add header for the warnings
b.addTextCell(wi1, 0, ri0, 'sObject Name',       xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1));
b.addTextCell(wi1, 1, ri1, 'Warning Message',    xlsx.StylesBuilder.getHeaderStyleIndex(1, 0, 1));


// Get all sorted nodes for the sObjects
Set<SortUtil.Node> nodes = SortSObjectsWithData.getSortedNodes();

// Extract the number of nodes for efficiency
Integer numberOfNodes    = nodes.size();
Integer numberOfWarnings = 0;

// Iterate all sorted nodes and add the lines to the sheet
for(SortUtil.Node node : nodes){
    
    // Up the row index
    ri0++;

    // Get the number of warnings for this node
    Integer numNodeWarnings = node.warnings?.size() ?? 0;

    // Add the row data
    b.addNumberCell(wi0, 0, ri0, node.order,                 xlsx.StylesBuilder.getMainStyleIndex(0, ri0, 0, 4, numberOfNodes));
    b.addTextCell(  wi0, 1, ri0, String.valueOf(node.node),  xlsx.StylesBuilder.getMainStyleIndex(1, ri0, 0, 4, numberOfNodes));
    b.addNumberCell(wi0, 2, ri0, node.depth,                 xlsx.StylesBuilder.getMainStyleIndex(2, ri0, 0, 4, numberOfNodes));
    b.addTextCell(  wi0, 3, ri0, node.path,                  xlsx.StylesBuilder.getMainStyleIndex(3, ri0, 0, 4, numberOfNodes));
    b.addNumberCell(wi0, 4, ri0, numNodeWarnings,            xlsx.StylesBuilder.getMainStyleIndex(4, ri0, 0, 4, numberOfNodes));

    // Up the number of warnings
    numberOfWarnings += numNodeWarnings;

    // Calculate the last row so we can apply the correct layout
    Integer maxRowIndex = (ri0==numberOfNodes) ? numberOfWarnings : 10000;

    // Add the warnings to the warnings sheet
    for(String warning : node.warnings ?? new String[]{}){

        // Up the row index
        ri1++;

        // Add the warning
        b.addTextCell(  wi1, 0, ri1, String.valueOf(node.node), xlsx.StylesBuilder.getMainStyleIndex(0, ri1, 0, 1, maxRowIndex));
        b.addTextCell(  wi1, 1, ri1, warning,                   xlsx.StylesBuilder.getMainStyleIndex(1, ri1, 0, 1, maxRowIndex));
    }
}


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
