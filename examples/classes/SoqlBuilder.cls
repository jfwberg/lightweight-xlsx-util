/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class to convert a SoqlParser result to an XLSX document
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 * @false-positive CognitiveComplexity      Way over the threshold, but this is because of the nature
 *                                          of lots of small XML writing statements with null cells. 
 *                                          Unless you split into many different files, the complexity 
 *                                          will be very high, but it's not difficult to read.
 * @false-positive CyclomaticComplexity     Caused by the many if statements and null checks for many
 *                                          individual XML element checks and validations
 * @false-positive StdCyclomaticComplexity  Just 1 over the threshold, I can live with that
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.OneDeclarationPerLine, PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
global with sharing class SoqlBuilder{

    // When set to to true, the labels are used 
    private static Boolean useLabels          = false;

    // When set to true, metadata tabs are included
    private static Boolean includeMetadata    = false;
    
    // Indicator if the default styles need to be applied or not
    private static Boolean applyDefaultStyles = false;
    

    /**
     * @description Method to enable labels instead of API names in the header
     */
    global static void useLabels(){
        useLabels = true;
    }

    /**
     * @description Method to enable the inclusion of metadata details
     */
    global static void includeMetadata(){
        includeMetadata = true;
    }


    /**
     * @description Method to enable the default XLSX Styles
     * @param b     The XLSX Builder class instance
     */
    global static void applyDefaultStyles(xlsx.Builder b){
        applyDefaultStyles = true;
        b.setIncludeDefaultStyles(true);
    }
    

    /**
     * @description Method to add records to the builder
     * @param b       The XLSX Builder class instance
     * @param records List of objects from either the API or serialized SObjects
     */
    global static void addRecords(xlsx.Builder b, Object[] records){
        
        // Add a new sheet for each sObjectType returned from the SOQL parser
        for(SoqlParser.SObjectType soqlWorksheet : SoqlParser.create(records)){
            
            // In order to put the right field in the matching column track the index for each field
            Map<String, Integer> fieldIndexMap = new Map<String, Integer>();

            // Create a worksheet for each sObjectType
            Integer wi = b.addWorksheet(soqlWorksheet.sObjectType);

            // Freeze the header row
            b.setFreezeRows(wi,1);

            // Differentiate between the parent sObject and child objects
            if(applyDefaultStyles){
                b.setTabColor(wi, soqlWorksheet.isParent ? 'F2DEFE' : 'F9F0FF');
            }

            // Keep track of the column index
            Integer ci = 0;

            // Number of fields, (last index)
            Integer endCi = soqlWorksheet.fields.size()-1;

            // Iterate all the fields in the query
            for(String fieldName : soqlWorksheet.fields.keySet()){

                // Add the header row for each field, populate either name or label
                b.addTextCell(
                    wi, ci, 0, 
                    useLabels ? soqlWorksheet.fields.get(fieldName).label : fieldName,
                    applyDefaultStyles ? xlsx.StylesBuilder.getHeaderStyleIndex(ci,0,endCi)  : null
                );
                
                // Create the field name / index mapping
                fieldIndexMap.put(fieldName, ci);

                // Up the column index
                ci++;
            }

            // Add row data for each query result
            for(Integer ri=0, max=soqlWorksheet.records.size(); ri<max; ri++){
                
                // Iterate all fields in the record 
                for(String fieldName : soqlWorksheet.records[ri].keySet()){
                    
                    // Extract the column index for performance
                    Integer rCi = fieldIndexMap.get(fieldName);

                    // Add the cell as a generic text cell
                    b.addTextCell(
                        wi, rCi, ri+1, 
                        soqlWorksheet.records[ri].get(fieldName).toString(),
                        applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(rCi, ri+1, 0, endCi, max) : null
                    );

                }
            }

            // If metadata needs to be included, add the metadata sheet
            if(includeMetadata){
                addMetadata(b, soqlWorksheet);
            }
        }       
    }
    



    /**
     * @description Adds metadata to the worksheet.
     * @param b              The builder object to add the metadata to.
     * @param soqlWorksheet  The SOQL parser sObjectType to use for the metadata.
     */
    private static void addMetadata(xlsx.Builder b, SoqlParser.SObjectType soqlWorksheet){
        
        // Create a worksheet for each sObjectType
        Integer wi = b.addWorksheet(soqlWorksheet.sObjectType + '.Metadata');

        // Set the row counter
        Integer ri=0;

        // Differentiate between the parent sObject and child objects
        if(applyDefaultStyles){
            b.setTabColor(wi, soqlWorksheet.isParent ? 'F2DEFE' : 'F9F0FF');
        }

        // Create a ap with sObject level metadata
        Map<String,Object> sObjectMetadata = new Map<String,Object>{
            'Is Parent sObject'       => soqlWorksheet.isParent,
            'Number of fields'        => soqlWorksheet.fields.size(),
            'Number of relationships' => soqlWorksheet.relationships.size(),
            'Number of records'       => soqlWorksheet.records.size()
        };

        // Add the header row for each field, populate either name or label
        b.addTextCell(wi, 0, ri, 'Attribute', applyDefaultStyles ? (xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1)+1) : null);
        b.addTextCell(wi, 1, ri, 'Value',     applyDefaultStyles ? (xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1)+1) : null);
        
        // Add an empty row
        ri++;

        // Calculate the last index
        Integer endRi = (sObjectMetadata.size()+ri) -1;

        // Add all sObject details
        for(String sObjectAttribute : sObjectMetadata.keySet()){
            b.addTextCell(wi, 0, ri, sObjectAttribute,                                 applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(0, ri, 0, 1, endRi) : null);
            b.addTextCell(wi, 1, ri, sObjectMetadata.get(sObjectAttribute).toString(), applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(1, ri, 0, 1, endRi) : null);
            ri++;
        }

        // Add an empty row
        ri++;

        // Create the relationship Header
        b.addTextCell( wi, 0, ri, 'Relationship Name', applyDefaultStyles ? xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1) : null);
        b.addTextCell( wi, 1, ri, 'Relationship Path', applyDefaultStyles ? xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1) : null);                
        b.addTextCell( wi, 2, ri, 'Relationship Depth',applyDefaultStyles ? xlsx.StylesBuilder.getHeaderStyleIndex(0, 0, 1) : null);

        // Calculate the row index for the last row so we can draw our style
        Integer endRelRi = (soqlWorksheet.relationships.size()-1) + ri;

        // Add the relationships row
        for(String relationshipName : soqlWorksheet.relationships.keySet()){
            
            // Up the row counter
            ri++;

            // Populate relationship cells
            b.addTextCell(   wi, 0, ri, relationshipName,                                       applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(0, ri, 0, 2, endRelRi) : null);
            b.addTextCell(   wi, 1, ri, soqlWorksheet.relationships.get(relationshipName).field,applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(1, ri, 0, 2, endRelRi) : null);
            b.addNumberCell( wi, 2, ri, soqlWorksheet.relationships.get(relationshipName).depth,applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(2, ri, 0, 2, endRelRi) : null);
        }

        // Add a blank line before the fields table
        ri=ri+2;
        
        // Create a list with field headers
        String[] fieldHeaders = new String[]{   'Field Name',     'Field Label',      'Field Type', 'Relationship Name',
                                                'Is External Id', 'Is Master Detail', 'Is Read Only'
        };

        // Add the header fields
        for(Integer hci=0,hcimax=fieldHeaders.size(); hci < hcimax; hci++){
            b.addTextCell (wi, hci, ri, fieldHeaders[hci],applyDefaultStyles ? xlsx.StylesBuilder.getHeaderStyleIndex(hci, 0, hcimax-1) : null);
        }

        // Add the number of rows for the correct offset for the styles
        Integer endFieldRi = soqlWorksheet.fields.size() + ri;

        // Add the relationships row
        for(String fieldName : soqlWorksheet.fields.keySet()){
            
            // Up the row counter
            ri++;

            // Populate field cells
            b.addTextCell(      wi, 0, ri, fieldName,applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(0, ri, 0, 6, endFieldRi) : null);
            b.addTextCell(      wi, 1, ri, soqlWorksheet.fields.get(fieldName).label,                   applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(1, ri, 0, 6, endFieldRi) : null);
            b.addTextCell(      wi, 2, ri, soqlWorksheet.fields.get(fieldName).type,                    applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(2, ri, 0, 6, endFieldRi) : null);
            b.addTextCell(      wi, 3, ri, soqlWorksheet.fields.get(fieldName).relationshipName,        applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(3, ri, 0, 6, endFieldRi) : null);
            b.addBooleanCell(   wi, 4, ri, soqlWorksheet.fields.get(fieldName).externalId,              applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(4, ri, 0, 6, endFieldRi) : null);
            b.addBooleanCell(   wi, 5, ri, soqlWorksheet.fields.get(fieldName).masterDetail ?? false,   applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(5, ri, 0, 6, endFieldRi) : null);
            b.addBooleanCell(   wi, 6, ri, soqlWorksheet.fields.get(fieldName).readOnly,                applyDefaultStyles ? xlsx.StylesBuilder.getMainStyleIndex(6, ri, 0, 6, endFieldRi) : null);   
        }
    }    
}