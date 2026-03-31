/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example of you can export your org's metadata details to an Excel sheet
 * @requires       Lightweight - SOAP Util v0.2 (/packaging/installPackage.apexp?p0=04tP3000000uNzdIAE)
 * @note           This is a bad implementation, but should give you an idea of how to use the builder
 * 
 * - https://medium.com/@justusvandenberg/a-lightweight-salesforce-metadata-api-apex-library-47c0b4c34131
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_List_Metadata.xlsx' );

// Set file properties
b.setTitle('List Metadata Example (' + xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('Metadata');
b.setDescription('An example of how you can create a report of your org\'s metadata.');

// Make it look fancy by adding the default styles
b.setIncludeDefaultStyles(true);

// Update with the number of metadata types (Max 10)
String[] metadataTypes = new String[]{
    'ApexClass',
    'CustomObject',
    'Profile',
    'PermissionSet'
};

// A list of header fields
String[] metadataFields = new String[]{
    'type',
    'createdById',
    'createdByName',
    'createdDate',
    'fileName',
    'fullName',
    'id',
    'lastModifiedById',
    'lastModifiedByName',
    'lastModifiedDate',
    'manageableState',
    'namespacePrefix'
};

// Use the size method only once
Integer numberOfMetadataFields = metadataFields.size();

// Iterate and add a tab for each metadata type
for(Integer i=0, iMax=metadataTypes.size(); i<iMax; i++){

    // Create a worksheet
    Integer wi = b.addWorksheet(metadataTypes[i]);

    // Add some colors to differentiate between the tabs
    b.setTabColor(wi,xlsx.CommonUtil.randomHtmlHexColorCode());

    // Set the row Index (start at 0 because we have a header)
    Integer ri = 0;

    // Create the header 
    for(Integer ci=0, ciMax=metadataFields.size(); ci<ciMax; ci++){
        b.addTextCell(wi, ci, ri, metadataFields[ci], xlsx.StylesBuilder.getHeaderStyleIndex(ci, ri, numberOfMetadataFields-1));
    }

    // Read metadata example: get the data for the User Object
    XmlStreamReader xsr = new soap.MdtWsdl('listMetadata')
        .addListMetadata(metadataTypes[i])
        .getXsr()
    ;

    // Treat texts as blocks to properly handle nulls
    xsr.setCoalescing(true);

    // Traverse the XML elements in the worksheet
    // I am not using while(xsr.hasNext()) to save a method call at the end of each item
    // For some reason it's about 30% faster to put an if statement at the end. No idea why.
    while(true){
        if(xsr.getEventType()==XmlTag.START_ELEMENT){

            // Basic error handling incase there is a soap error
            if(xsr.getLocalName() == 'faultstring'){
                xsr.next();
                throw new StringException('Metadata API Arror: ' + xsr.getText());
            }

            // Each record starts with a result, so we create a row here
            if(xsr.getLocalName() == 'result'){
                ri++;
            }

            // Create a column for each field in the metadata
            for(Integer ci=0, ciMax=metadataFields.size(); ci<ciMax; ci++){
                if(xsr.getLocalName() == metadataFields[ci]){
                    xsr.next();
                    if(xsr.getEventType()==XmlTag.CHARACTERS && xsr.hasText()){
                        
                        // We don't know the last row, so in the styling just always add one (ri+1) and accept an ugly last row
                        b.addTextCell(wi, ci, ri, xsr.getText(), xlsx.StylesBuilder.getMainStyleIndex(ci, ri, 0, 1, ri+1));
                    }
                }
            }
        }

        // If there is a next element go to the next element, else we're done
        if(xsr.hasNext()){ xsr.next(); } else { break; }
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
