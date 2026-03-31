/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example on exporting your org's current record count
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Configure the builder to use the shared strings index instead of inline strings
b.setUseSharedStrings(true);

// This option creates the default set of "table" styles
// Can be used to use a default styling for all sheets, (will take a small performance hit)
b.setIncludeDefaultStyles(true);

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_record_count.xlsx' );

// Set file properties
b.setTitle('Record Count (' + xlsx.CommonUtil.getTimestampString() + ')');
b.setSubject('Record Count');
b.setDescription('Get the record count from an org');
b.addKeyword('Record');
b.addKeyword('Count');

// Create the worksheet name based on the object
Integer wi = b.addWorksheet('Record Count');

// Give our tab a festive color (random color)
b.setTabColor(wi, xlsx.CommonUtil.randomHtmlHexColorCode());

// Enable the filter options for the first row
b.setAutoFilter(wi,true);

// Freeze the header row 
b.setFreezeRows(wi, 1);

// Set the last column index (5 columns -1)
Integer lastColumnIndex = 7;

// add header cells
b.addTextCell(wi, 0, 0, 'Key Prefix',     StylesBuilder.getHeaderStyleIndex(0, 0, lastColumnIndex));
b.addTextCell(wi, 1, 0, 'Name',           StylesBuilder.getHeaderStyleIndex(1, 0, lastColumnIndex));
b.addTextCell(wi, 2, 0, 'Count',          StylesBuilder.getHeaderStyleIndex(2, 0, lastColumnIndex));
b.addTextCell(wi, 3, 0, 'Queryable',      StylesBuilder.getHeaderStyleIndex(3, 0, lastColumnIndex));
b.addTextCell(wi, 4, 0, 'Creatable',      StylesBuilder.getHeaderStyleIndex(4, 0, lastColumnIndex));
b.addTextCell(wi, 5, 0, 'Updateable',     StylesBuilder.getHeaderStyleIndex(5, 0, lastColumnIndex));
b.addTextCell(wi, 6, 0, 'Deletable',      StylesBuilder.getHeaderStyleIndex(6, 0, lastColumnIndex));
b.addTextCell(wi, 7, 0, 'Custom Setting', StylesBuilder.getHeaderStyleIndex(7, 0, lastColumnIndex));


// Create the service Object that queries the record usage
StorageUsageService sus = new StorageUsageService();

// Add data rows and cells
for (Integer ri = 0, riMax=sus.storageUsageList.size(); ri < riMax; ri++){
    b.addTextCell   (wi, 0, ri+1, sus.storageUsageList[ri].keyPrefix,       StylesBuilder.getMainStyleIndex(0, ri+1, 0, lastColumnIndex, riMax));
    b.addTextCell   (wi, 1, ri+1, sus.storageUsageList[ri].name,            StylesBuilder.getMainStyleIndex(1, ri+1, 0, lastColumnIndex, riMax));
    b.addNumberCell (wi, 2, ri+1, sus.storageUsageList[ri].count,           StylesBuilder.getMainStyleIndex(2, ri+1, 0, lastColumnIndex, riMax));
    b.addBooleanCell(wi, 3, ri+1, sus.storageUsageList[ri].isQueryable,     StylesBuilder.getMainStyleIndex(3, ri+1, 0, lastColumnIndex, riMax));
    b.addBooleanCell(wi, 4, ri+1, sus.storageUsageList[ri].isCreateable,    StylesBuilder.getMainStyleIndex(4, ri+1, 0, lastColumnIndex, riMax));
    b.addBooleanCell(wi, 5, ri+1, sus.storageUsageList[ri].isUpdateable,    StylesBuilder.getMainStyleIndex(5, ri+1, 0, lastColumnIndex, riMax));
    b.addBooleanCell(wi, 6, ri+1, sus.storageUsageList[ri].isDeletable,     StylesBuilder.getMainStyleIndex(6, ri+1, 0, lastColumnIndex, riMax));
    b.addBooleanCell(wi, 7, ri+1, sus.storageUsageList[ri].isCustomSetting, StylesBuilder.getMainStyleIndex(7, ri+1, 0, lastColumnIndex, riMax));
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


/** **************************************************************************************************** **
 **                                          ADDITIONAL CLASSES                                          **
** **************************************************************************************************** **/
/**
 *	Class containing services regarding Salesforce Storage Usage & Analysis
*/
public class StorageUsageService{
    
    // Run global describe only once for performance
    private Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

    // Create new Storage Usage list for holding the API responses
    public StorageUsage[] storageUsageList = new StorageUsage[]{};
    
    /**
     *	CONSTRUCTOR
    */
    public StorageUsageService(){
        // Populate the storage list from the API, this action is always required
        this.populateStorageUsageListFromApi();
    }
    
    /* **************************************************************************
    *							PRIVATE METHODS
    * **************************************************************************/
    /**
     *	Method for population the Storage Usage List with API details
    */
    private void populateStorageUsageListFromApi(){

        // Create new request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm()+ '/services/data/v63.0/limits/recordCount');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        HttpResponse response = http.send(request);

        // Check response code
        if (response.getStatusCode() == 200) {

            // Parse API response
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            // Populate storage list, note fasted JSON parsing happens when directly going into a constructor instead of creating a variable assignment first
            for(Object objMap : (Object[]) responseMap.get('sObjects')){
                this.storageUsageList.add(new StorageUsage((Map<String,Object>) objMap, this.gd));
            }

            // Sort the list by number of records
            this.storageUsageList.sort();

        }else{
            // I cannot be bothered with error handling for this, so simply put the response to read here
            System.debug('Response code NOT OK: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
        }
    }
}


/**
 *	Class for storage usage so we can sort on the count properly
*/
public class StorageUsage implements Comparable{
    
    public String  keyPrefix;
    public String  name;
    public String  label;
    public Integer count;
    public Boolean isQueryable;
    public Boolean isCreateable;
    public Boolean isUpdateable;
    public Boolean isDeletable;
    public Boolean isCustomSetting;
    
    
    // CONSTRUCTOR 
    public StorageUsage(Map<String,Object> objMap, Map<String, Schema.SObjectType> gd){
        
        // Type case from field mapping
        this.name  = (String) objMap.get('name');
        this.count = (Integer)objMap.get('count');
        
        // Get describe for the sObject and extract the child relationships and assign to the object
        Schema.DescribeSObjectResult dsr = 	gd.get(this.name).getDescribe(SObjectDescribeOptions.DEFERRED);

        // Set values
        this.keyPrefix      = dsr.getKeyPrefix();
        this.label          = dsr.getLabel();
        this.isQueryable    = dsr.isQueryable();
        this.isCreateable   = dsr.isCreateable();
        this.isUpdateable   = dsr.isUpdateable();
        this.isDeletable    = dsr.isDeletable();
        this.isCustomSetting= dsr.isCustomSetting();
    }
    
    /**
     *	Compare interface, specifically so we can sort on the count DESC
    */
    public Integer compareTo(Object compareTo) {
        StorageUsage compareToStorageUsage = (StorageUsage)compareTo; 
        Integer returnValue = 0;
        if (this.count > compareToStorageUsage.count) {
            returnValue = -1;
        } else if (this.count < compareToStorageUsage.count) {
            returnValue = 1;
        } else if ((this.count == null) && (compareToStorageUsage.count != null)){
            returnValue = 1;
        } else if ((this.count != null) && (compareToStorageUsage.count == null)){
            returnValue = -1;
        }
        return returnValue;
    }
}