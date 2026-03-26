/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    An example of how you parse the result of a SOQL query directly to a multi tabbed XLSX file
 *                 For each sOBject
 * 
 * @note           REQUIRES SoqlParser and SoqlBuilder classes to be in the org
 * 
 * - https://medium.com/@justusvandenberg/dynamically-handle-salesforce-soql-subquery-response-data-using-apex-8130bd0622aa
 * - https://www.thiscodeworks.com/apex-soqltableparser-soql-subqueries-to-a-single-flat-table/66ba81bc2e62a20014b9150c
 * - https://www.thiscodeworks.com/apex-soqlmultitableparser-soql-subqueries-to-multiple-individual-tables/66ba816f2e62a20014b913aa
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Configure the builder to use the shared strings index instead of inline strings
b.setUseSharedStrings(true);

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_SOQL_Query_With_Child_Queries_Example.xlsx' );

// Set file properties
b.setTitle('SOQL Query With Child Queries Example (' + xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('SOQL Queries');
b.setDescription('An example of how you parse the result of a SOQL query directly to a multi tabbed XLSX file');
b.addKeyword('SOQL');

// Use labels instead of API Names in the header
SoqlBuilder.useLabels();

// Metadata information for the fields is included in separate tabs
SoqlBuilder.includeMetadata();

// Apply the default styling for SOQL Tabs to the builder
SoqlBuilder.applyDefaultStyles(b);

// Add the records to the SOQL Builder
// This method should only run once to prevent strange behavior
SoqlBuilder.addRecords(b, getObjectList());

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

/**
 * Method to get records from a Query as an example
 */
private Object[] getObjectList(){
    return (Object[])JSON.deserializeUntyped(JSON.serialize([
        SELECT 
            Id, Name, CreatedDate,
            (
                SELECT 
                    Id, CreatedDate, LastModifiedDate,
                    Owner.Name, Owner.Profile.Name, 
                    AccountId, FirstName, LastName
                FROM
                    Contacts
                WHERE Name LIKE 'LWT - Test - %' ORDER BY Name ASC LIMIT 10
            ),
            (
                SELECT
                    Id, CreatedDate, LastModifiedDate,
                    Owner.Name, Owner.Profile.Name,
                    CaseNumber, Subject, Status 
                FROM 
                    Cases
                WHERE Subject LIKE 'LWT - Test - %' ORDER BY Subject ASC LIMIT 10
            ),
            (
                SELECT
                    Id, CreatedDate, LastModifiedDate,
                    Owner.Name, Owner.Profile.Name,
                    Name, StageName, CloseDate,
                    (
                        SELECT
                            Id, ContactId , OpportunityId, Opportunity.Account.Id 
                        FROM 
                            OpportunityContactRoles
                        LIMIT 10
                    )
                FROM 
                    Opportunities
                WHERE Name LIKE 'LWT - Test - %' ORDER BY Name ASC LIMIT 10
            )
        FROM 
            Account 
        WHERE Name LIKE 'LWT - Test - %' ORDER BY Name ASC LIMIT 10
    ]));
     
}