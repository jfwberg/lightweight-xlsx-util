/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Examples on how to parse an XLSX file stored as a document
 * @examples       Parse to Multi-Dimensional Array and convert
 *                 the result to a list of SObjects
 * @note           This method uses the toArrayInverted() method to have record
 *                 rows before columns instead of the other way around
 *                 Depending on your file sizes, use toArrayInvertedDomDoc() for 
 *                 performance improvements
 * @note           - Worksheets need to have the sObject API Name as their name
 *                 - The first line of the worksheet requires the API fields in the header
 *                 - Basic field validation like read-only is applied and required
 *                 - This is an example that is relatively efficient and scales
 *                   pretty well. I would review it for production implementations though 
 */
/** ****************************************************************************** **
 *     Parse to Multi-Dimensional Array and convert to a list of sObject Lists
 ** ****************************************************************************** **/
try{
    // List to store errors or warnings
    String[] warnings = new String[]{};

    // Create a new list of sObject lists for the output of each worksheet
    SObject[][] sObjectLists = new SObject[][]{};
    
    // Unzip the whole xlsx file, make sure the XLSX file only contains existing sObjects
    Map<String,Compression.ZipEntry> entries = new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Q1000004jD23IAE' LIMIT 1]?.Body
    ).getEntriesMap();

    // Get an index for all the worksheets, because we need the worksheet name as sObject API name
    Map<String,Integer> worksheetNameIndexMap =  xlsx.Parse.toWorksheetNameIndexMap(entries); 
    
    // Create a list with the worksheet names so we can reference it using the index
    String[] worksheetNameList = new List<String>(worksheetNameIndexMap.keySet());

    // Keep track of the current worksheet
    Integer wi = -1;

    // Iterate each worksheet as each worksheet (should) contain it's own sObject
    for(Object[][] worksheet : xlsx.Parse.toArrayInvertedDomDoc(entries)){
        
        // Set the worksheet index. It's important to keep track of the indexes
        wi++;

        // Extract the sObject name
        String sObjectName = worksheetNameList[wi];

        // Create a list of sObjects for the current worksheet
        SObject[] sObjectList = (SObject[]) Type.forName( 'List<'+sObjectName+'>' )?.newInstance();

        // Check if the sObject in the worksheet name exists in the metadata, if not add a single empty cell
        // and go to the next worksheet
        if(sObjectList == null){
            warnings.add('No sObject with the name "'+sObjectName+'" found in the metadata');
            continue;
        }
                
        // Get a list of field names from the first row
        // It needs to be a list so we can simply reference it by index for performance reasons
        String[] fieldNames = new String[]{};

        // Create a list of field names so we can reference the display type based on an index
        Schema.DisplayType[] fieldTypes = new Schema.DisplayType[]{};

        // Create a check list where we can use an index to determine if a fields needs to be skipped
        // This allows for a single check. Same performance trick as above. An index reference is the fastest
        Boolean[] skipFields =  new Boolean[]{};

        // Place to store the field describes for the current sObject
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();

        // Process the header row
        processHeaderRow(
            sObjectName,
            worksheet[0], 
            sObjectList.getSObjectType().getDescribe().fields.getMap(),
            fieldNames,
            fieldTypes,
            skipFields,
            fieldDescribeMap,
            warnings
        );
        
        // Process all the rows except the header row
        processDataRows(
            sObjectName,
            worksheet,
            fieldNames,
            fieldTypes,
            skipFields,
            fieldDescribeMap,
            sObjectList
        );

        // Add the sObject list to the output
        sObjectLists.add(sObjectList);
    }

    // Output any warnings on the import
    for(String warning : warnings){
        System.debug('WARNING: ' + warning);
    }

    // Output the results of what we have done
    for(SObject[] sObjectList : sObjectLists){
        System.debug('sObjectType: "' + sObjectList.getSObjectType() + '" contains ' + sObjectList.size() + ' records');
    }

// Catch a Zip Specific Exception
}catch(Compression.ZipException e){
    System.debug('ZIP EXCEPTION: ' + e.getMessage());

// Catch an XLSX Parser Specific Exception
}catch(xlsx.ParseException e){
    System.debug('PARSE EXCEPTION: ' + e.getMessage());

// Catch and handle any other type of Exception
}catch(Exception e){
    System.debug('UNKNOWN EXCEPTION: ' + e.getMessage() + e.getStackTraceString());
}


/**
 * @description Method that processes the data rows and puts the data into SObject records
 *              - Start at row 1, because row 0 should be the header row
 *              - Type cast a new sObject based on the sObject name
 *              - Skip the field if skip is true in the skip fields array
 * 
 */
private static void processDataRows(String    sObjectName, Object[][]                              worksheet,         String[]  fieldNames, Schema.DisplayType[] fieldTypes,
                                    Boolean[] skipFields,  Map<String, Schema.DescribeFieldResult> fieldDescribeMap,  SObject[] sObjectList){
    // Iterate the rows
    for(Integer ri=1, max=worksheet.size(); ri<max; ri++){
            
        // Create a new sObject
        SObject sObj = (SObject) Type.forName( sObjectName ).newInstance();

        // Populate the sObject with the values from the current row
        for(Integer ci=0, cMax=worksheet[0].size();ci<cMax;ci++){

            // If there are any issues in the field we can skip it
            if(skipFields[ci]){
                 continue;
            }
            
            // Put in the field value dynamically
            sObj.put(
                fieldNames[ci],
                castObjectFieldData(
                    fieldTypes[ci],
                    worksheet[ri][ci]
                )
            );
        }

        // Add the sObject to the list
        sObjectList.add( sObj );
    }
}


/**
 * @description Method that executes the field validation, it checks the fields exist
 *              It runs a describe for each field to check if it is updatable
 *              If the field is not found it is skipped
 *              If the field is found but not updatable it is skipped
 *              Adds a warning in case of any errors
 */
private static void processHeaderRow(String               sObjectName, Object[]  headerRow,  Map<String, Schema.SObjectField>        fieldMap,         String[] fieldNames,
                                     Schema.DisplayType[] fieldTypes,  Boolean[] skipFields, Map<String, Schema.DescribeFieldResult> fieldDescribeMap, String[] warnings){

    // Iterate the columns in the header row
    for(Integer ci=0, ciMax=headerRow.size(); ci<ciMax; ci++){
            
        // Add the field name to the list
        String fieldName = (String) headerRow[ci];

        // add field name, adding them all makes it easier to prevent an out of bounds errors
        fieldNames.add(fieldName);

        // Check the field exists in the metadata
        if(!fieldMap.containsKey( fieldName )){
            
            // prevent out of bounds
            fieldTypes.add(null);

            // This field can be skipped as it does not exist
            skipFields.add(true);

            // Add a warning
            warnings.add(sObjectName + '.' + fieldName + ' does not exist and is skipped');
            
            // Next field
            continue;
        }

        // If the field exists, describe the field so the describe can be reused
        fieldDescribeMap.put(fieldName, fieldMap.get(fieldName).getDescribe());

        // Add the field type to the list so it can be reference using an index
        // and the getType() method is executed only once for each field
        fieldTypes.add(fieldDescribeMap.get(fieldName).getType());

        // Check the field is creatable or updateable
        if(fieldName?.toLowerCase() != 'id' && !fieldDescribeMap.get(fieldName).isUpdateable()){
            skipFields.add(true);
            warnings.add(sObjectName + '.' + fieldName + ' is creatable nor updateable and skipped');
            continue;
        }

        // If there are no issues the fields, it does not have to be skipped
        skipFields.add(false);
    }
}


/**
 * @description Casts the field data to the Apex data type
 * @param fieldType  The DisplayType of the field
 * @param fieldValue The value of the field
 * @return      The field data cast to the matching data type
 */
public static Object castObjectFieldData(Schema.DisplayType fieldType, Object fieldValue) {
    switch on fieldType {
        when STRING, TEXTAREA, URL, PHONE, EMAIL {
            return fieldValue.toString();
        }
        when DOUBLE, CURRENCY, PERCENT {
            return Double.valueOf(fieldValue);
        }
        when DATE {
            return Date.valueOf(fieldValue.toString());
        }
        when DATETIME {
            return Datetime.valueOf(fieldValue.toString());
        }
        when BOOLEAN {
            return Boolean.valueOf(fieldValue);
        }
        when INTEGER {
            return Integer.valueOf(fieldValue);
        }
        when else {
            return fieldValue;
        }
    }
}