/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example to create a field overview for multiple sObjects where we put
 *                 each object in it's own sheet (batchefy if you want everything)
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Because we have repetition for each sObject (field names),
// use shared strings instead of inline strings for a better overall performance
b.setUseSharedStrings(true);

// This option creates the default set of "table" styles
// Can be used to use a default styling for all sheets, (will take a small performance hit)
b.setIncludeDefaultStyles(true);
 
// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_sObject_Documentation.xlsx' );

// Set file properties
b.setTitle('sObject Documentation ('+xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('sObject Documentation');
b.setDescription('Overview of a number of sObjects and their fields');
b.addKeyword('sObject');
b.addKeyword('Fields');

// Create the object index worksheet (first worksheet will have index 0)
b.addWorksheet('Index');

// Add header row to the Index sheet
b.addTextCell(0, 0, 0, '#');
b.addTextCell(0, 1, 0, 'Key Prefix');
b.addTextCell(0, 2, 0, 'Name');
b.addTextCell(0, 3, 0, 'Label');
b.addTextCell(0, 4, 0, 'Custom');
b.addTextCell(0, 5, 0, 'Custom Setting');
b.addTextCell(0, 6, 0, 'Feed enabled');
b.addTextCell(0, 7, 0, 'Searchable');

// Apply the header cell styles
// getHeaderStyleIndex(Integer ci, Integer startCi, Integer endCi)
b.setCellStyle(0, 0, 0, xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 7));
b.setCellStyle(0, 1, 0, xlsx.StylesBuilder.getHeaderStyleIndex(1, 0, 7));
b.setCellStyle(0, 2, 0, xlsx.StylesBuilder.getHeaderStyleIndex(2, 0, 7));
b.setCellStyle(0, 3, 0, xlsx.StylesBuilder.getHeaderStyleIndex(3, 0, 7));
b.setCellStyle(0, 4, 0, xlsx.StylesBuilder.getHeaderStyleIndex(4, 0, 7));
b.setCellStyle(0, 5, 0, xlsx.StylesBuilder.getHeaderStyleIndex(5, 0, 7));
b.setCellStyle(0, 6, 0, xlsx.StylesBuilder.getHeaderStyleIndex(6, 0, 7));
b.setCellStyle(0, 7, 0, xlsx.StylesBuilder.getHeaderStyleIndex(7, 0, 7));

// Update the column width for the number column
b.setColWidth(0,0,4);

// Create a list of sObjects we want to add as worksheets
buildCustomObjectWorksheet(
    b,
    new SObjectType[]{
        Account.getSObjectType(),
        Case.getSObjectType(),
        Contact.getSObjectType(),
        Event.getSObjectType(),
        Lead.getSObjectType(),
        Opportunity.getSObjectType(),
        Task.getSObjectType(),
        User.getSObjectType(),
        Organization.getSObjectType()
});

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


private static void buildCustomObjectWorksheet(xlsx.Builder b, SObjectType[] objects){
    
    // Extract the number of objects so we can style the bottom row
    // 1 Header rows + objects size - 1 for zero index to even it out
    Integer lastRowIndex = objects.size();

    // Build a sheet for each object in the org
    for(Integer i =0,max=objects.size(); i<max; i++){
        buildCustObjSheets(b, objects[i].getDescribe(SObjectDescribeOptions.DEFERRED) , i+1, lastRowIndex);
    }
}


private static void buildCustObjSheets(xlsx.Builder b, Schema.DescribeSObjectResult dsr, Integer ri, Integer lastRowIndex){

    // In this example give me all objects that I can read, query and that have a key prefix
    if(dsr.isAccessible() && dsr.isQueryable() && dsr.getKeyPrefix() != null){

        // Create a tab name with the object prefix and the truncated name
        String tabName = ((dsr.getName().length() > 25) ? dsr.getName().substring(25) : dsr.getName()) + ' ('+ dsr.getKeyPrefix() +')';

        // Add entry to the index sheet
        b.addNumberCell( 0, 0, ri, ri);
        b.addTextCell(   0, 1, ri, dsr.getKeyPrefix());
        b.addTextCell(   0, 2, ri, dsr.getName());        
        b.addTextCell(   0, 3, ri, dsr.getLabel());
        b.addBooleanCell(0, 4, ri, dsr.isCustom());
        b.addBooleanCell(0, 5, ri, dsr.isCustomSetting());
        b.addBooleanCell(0, 6, ri, dsr.isFeedEnabled());
        b.addBooleanCell(0, 7, ri, dsr.isSearchable());

        // Apply default styling
        // getMainStyleIndex(Integer ci, Integer ri, Integer startCi, Integer endCi, Integer endRi)
        b.setCellStyle(0, 0, ri, xlsx.StylesBuilder.getMainStyleIndex(0, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 1, ri, xlsx.StylesBuilder.getMainStyleIndex(1, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 2, ri, xlsx.StylesBuilder.getMainStyleIndex(2, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 3, ri, xlsx.StylesBuilder.getMainStyleIndex(3, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 4, ri, xlsx.StylesBuilder.getMainStyleIndex(4, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 5, ri, xlsx.StylesBuilder.getMainStyleIndex(5, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 6, ri, xlsx.StylesBuilder.getMainStyleIndex(6, ri, 0, 7, lastRowIndex));
        b.setCellStyle(0, 7, ri, xlsx.StylesBuilder.getMainStyleIndex(7, ri, 0, 7, lastRowIndex));
        
        // Add a link to the name cell to go to the matching tab
        b.addHyperLink(
            0,                          // Worksheet index
            2,                          // Column index
            ri,                         // Row index
            '\''+ tabName +'\'!A1',     // Location
            dsr.getName()               // Display
        );
        
        // Create a new worksheet based for the sObject
        Integer wi = b.addWorksheet(tabName);

        // We know there are a maximum of 1000 fields due to the limit of 800 custom fields per object
        // with about a 100 info rows. Use pre-pad to improve the performance
        //b.prePadWorksheet(wi, 10, 1000);

        // Give our tab a random color, this make testing easier
        b.setTabColor(wi,xlsx.CommonUtil.randomHtmlHexColorCode());

        // Freeze the first 2 rows and first 3 columns
        b.setFreezeRows(wi, 2);
        b.setFreezeColumns(wi, 2);

        // Add the header names to the header row
        b.addTextCell(wi, 1, 0, ' ');
        b.addTextCell(wi, 2, 0, ' ');
        b.addTextCell(wi, 3, 0, ' ');
        b.addTextCell(wi, 4, 0, ' ');
        b.addTextCell(wi, 5, 0, ' ');
        b.addTextCell(wi, 6, 0, ' ');
        
        // Add style to the top header row
        b.setCellStyle(wi, 1, 0, xlsx.StylesBuilder.getHeaderStyleIndex(1, 0, 6));
        b.setCellStyle(wi, 2, 0, xlsx.StylesBuilder.getHeaderStyleIndex(2, 0, 6));
        b.setCellStyle(wi, 3, 0, xlsx.StylesBuilder.getHeaderStyleIndex(3, 0, 6));
        b.setCellStyle(wi, 4, 0, xlsx.StylesBuilder.getHeaderStyleIndex(4, 0, 6));
        b.setCellStyle(wi, 5, 0, xlsx.StylesBuilder.getHeaderStyleIndex(5, 0, 6));
        b.setCellStyle(wi, 6, 0, xlsx.StylesBuilder.getHeaderStyleIndex(6, 0, 6));

        // Make the header row size bigger
        b.setRowHeight(wi,0,20);
      
        // Add the header names to the header row
        b.addTextCell(wi, 0, 1, '#');
        b.addTextCell(wi, 1, 1, 'Name');
        b.addTextCell(wi, 2, 1, 'Label');
        b.addTextCell(wi, 3, 1, 'Type');
        b.addTextCell(wi, 4, 1, 'SoapType');
        b.addTextCell(wi, 5, 1, 'Relationship Name');
        b.addTextCell(wi, 6, 1, 'Related to');

        // Add style to the top header row
        b.setCellStyle(wi, 0, 1, xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 6));
        b.setCellStyle(wi, 1, 1, xlsx.StylesBuilder.getHeaderStyleIndex(1, 0, 6));
        b.setCellStyle(wi, 2, 1, xlsx.StylesBuilder.getHeaderStyleIndex(2, 0, 6));
        b.setCellStyle(wi, 3, 1, xlsx.StylesBuilder.getHeaderStyleIndex(3, 0, 6));
        b.setCellStyle(wi, 4, 1, xlsx.StylesBuilder.getHeaderStyleIndex(4, 0, 6));
        b.setCellStyle(wi, 5, 1, xlsx.StylesBuilder.getHeaderStyleIndex(5, 0, 6));
        b.setCellStyle(wi, 6, 1, xlsx.StylesBuilder.getHeaderStyleIndex(6, 0, 6));

        // Start the row index at 2 because we have a header and a sub header
        Integer rowIndex = 2;

        // calculate the last row index for the default styles
        Integer lastFieldRowIndex = dsr.fields.getMap().size() + rowIndex -1;

        // Add the fields to the sheet
        for(String fieldName : dsr.fields.getMap().keySet()){
            addFieldCells(
                b,
                wi,
                rowIndex,
                dsr.fields.getMap().get(fieldName).getDescribe(FieldDescribeOptions.DEFAULT),
                lastFieldRowIndex
            );
            rowIndex++;
        }
    }
}

// Create a row of cells
private static void addFieldCells(xlsx.Builder b, Integer wi, Integer ri, Schema.DescribeFieldResult dfr, Integer lastFieldRowIndex){
    // Add a link back to the index tab
    b.addTextCell( wi, 0, 0, 'Index', xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1));
    b.addHyperLink(wi, 0, 0, '\'Index\'!A1', 'Index');

    // Add cells
    b.addNumberCell(wi, 0, ri, ri-1);
    b.addTextCell(wi, 1, ri, dfr.getName());
    b.addTextCell(wi, 2, ri, dfr.getLabel());
    b.addTextCell(wi, 3, ri, String.valueOf(dfr.getType()));
    b.addTextCell(wi, 4, ri, String.valueOf(dfr.getSoapType()));
    b.addTextCell(wi, 5, ri, String.valueOf(dfr.getRelationshipName()));
    b.addTextCell(wi, 6, ri, String.valueOf((dfr.getType() == Schema.DisplayType.REFERENCE && dfr.getReferenceTo().size() > 0) ? String.valueOf(dfr.getReferenceTo()[0]) : ''));

    // Add styles
    b.setCellStyle(wi, 0, ri,  xlsx.StylesBuilder.getMainStyleIndex(0, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 1, ri,  xlsx.StylesBuilder.getMainStyleIndex(1, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 2, ri,  xlsx.StylesBuilder.getMainStyleIndex(2, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 3, ri,  xlsx.StylesBuilder.getMainStyleIndex(3, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 4, ri,  xlsx.StylesBuilder.getMainStyleIndex(4, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 5, ri,  xlsx.StylesBuilder.getMainStyleIndex(5, ri, 0, 6, lastFieldRowIndex));
    b.setCellStyle(wi, 6, ri,  xlsx.StylesBuilder.getMainStyleIndex(6, ri, 0, 6, lastFieldRowIndex));    
}