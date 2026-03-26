/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example of exporting your current limits to an XLSX format
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// This option creates the default set of "table" styles
// Can be used to use a default styling for all sheets, (will take a small performance hit)
b.setIncludeDefaultStyles(true);
 
// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_limit_usage.xlsx' );

// Set file properties
b.setTitle('Limit Usage (' + xlsx.CommonUtil.getTimestampString() + ')');
b.setSubject('Limit Usage');
b.setDescription('Get the limit consumption from an org');
b.addKeyword('Limit');
b.addKeyword('Usage');

// Create the worksheet name based on the object
Integer wi = b.addWorksheet('Limit Usage');

// Give our tab a festive color (random color)
b.setTabColor(wi, xlsx.CommonUtil.randomHtmlHexColorCode());

// Enable the filter options for the first row
b.setAutoFilter(wi,true);

// Freeze the header row 
b.setFreezeRows(wi, 1);

// Header fields
String[] headerFields = new String[]{'Limit Name','Usage Value', 'Maximum Limit','Remaining'};

// Create the data array
List<List<Object>> dataArray = new List<List<Object>>();

// Add data lines from the org limits
for(String key : OrgLimits.getMap().keySet()){
    System.OrgLimit orgLimit = OrgLimits.getMap().get(key);
    dataArray.add(
        new Object[]{
            orgLimit.getName(),
            orgLimit.getValue(),
            orgLimit.getLimit(),  
            (orgLimit.getLimit() - orgLimit.getValue())
        }
    );
}

// add header cells
for (Integer ci = 0,ciMax=headerFields.size(); ci < ciMax; ci++) {
    b.addTextCell(wi,ci,0,headerFields[ci],xlsx.StylesBuilder.getHeaderStyleIndex(0, ci, headerFields.size()-1));
}

// Populate the rows with data
for(Integer ri=0, riMax=dataArray.size()-1;ri<=riMax;ri++){
    for(Integer ci=0, ciMax=dataArray[ri].size()-1;ci<=ciMax;ci++){
        if(ci<1){
            b.addTextCell(
                wi,
                ci,
                ri+1, // +1 for the header offset
                String.valueOf(dataArray[ri][ci]),
                xlsx.StylesBuilder.getMainStyleIndex(ci, ri+1, 0, ciMax, riMax+1)
            );
        }else{
            b.addNumberCell(
                wi,
                ci,
                ri+1, // +1 for the header offset
                Integer.valueOf(dataArray[ri][ci]),
                xlsx.StylesBuilder.getMainStyleIndex(ci, ri+1, 0, ciMax, riMax+1)
            );
        }
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