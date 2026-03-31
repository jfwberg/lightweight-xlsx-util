/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           March 2026
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class converting a list of Selected Flow Choices with Integers as values
 *                 to a list of Integers
 *
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.

 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FlowWorksheetList {

    /**
     * @description Converts the latest ContentVersion of the provided ContentDocument into LLM-readable text.
     *              Optionally prefixes default interpretation instructions based on the request.
     * @param requests A single-element array containing the Request with ContentDocumentId and options.
     * @return      An array with a single Response. On success, Response.isSuccess=true and Response.llmText contains the output.
     *              On failure, returns a single Response with isSuccess=false and errorMessage populated.
     * @throws      StringException Thrown when requests is empty, ContentDocumentId is missing/invalid, or file extension is not xlsx.
     * @throws      QueryException  Thrown if the current user lacks access or the ContentDocumentId is invalid.
     */ 
    @InvocableMethod(label='Get List of Worksheet Names from XLSX' description='Takes an XLSX file (ContentDocument Id) as input and retrieves the availible worksheets')
    global static Response[] getAll(Request[] requests) {
        try {
            // Validate input using a helper method
            validateRequests(requests);
         
            Map<String,Integer> worksheetNameIndexMap = xlsx.Parse.toWorksheetNameIndexMap(
                new Compression.ZipReader(
                    validateXlsx([
                    SELECT FileExtension, VersionData FROM ContentVersion
                    WHERE ContentDocumentId = :requests[0].contentDocumentIds[0] 
                    AND IsLatest = true 
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                    ][0])
                )?.getEntriesMap()
            );

            // Create a list f choices
            FlowChoice[] flowChoices = new FlowChoice[]{};

            // Populate the choices
            for(String worksheetName : worksheetNameIndexMap.keySet()){
                flowChoices.add(new FlowChoice(
                    worksheetName,
                    worksheetNameIndexMap.get(worksheetName)?.toString()
                ));
            }

            // Return the choices
            return new Response[]{new Response(flowChoices)};

        }catch(Exception e) {
            return new Response[]{new Response(false,String.format(FlowConstant.MSG_GET_WS_LIST_UNKNOWN_ERROR, new String[]{e.getMessage()}) )};
        }
    }
    

    /**
     * @description Validates the input Request array and ensures a valid ContentDocumentId of type ContentDocument.
     * @param requests The incoming Flow request payload to validate.
     * @throws      StringException When the request array is empty, the Id is missing, or not a ContentDocument Id.
     */
    private static void validateRequests(Request[] requests){
        
        // Validate we have some requests coming in
        if(requests == null || requests?.isEmpty()){
            throw new StringException(FlowConstant.MSG_REQUEST_PARAM_REQUIRED);
        }
    
        // Validate the request input
        if (requests[0].contentDocumentIds[0] == null){
            throw new StringException(FlowConstant.MSG_CONTENT_DOCUMENT_ID_REQUIRED);
        }

        // Validate SObject type using getSObjectType() to ensure proper type checking
        if (requests[0].contentDocumentIds[0].getSObjectType() != ContentDocument.SObjectType) {
            throw new StringException(FlowConstant.MSG_INVALID_CONTENT_DOCUMENT_ID);
        }
    }


    /**
     * @description Validates that the provided ContentVersion is an XLSX and returns its VersionData blob.
     * @param cv The ContentVersion record from the ContentDocument query.
     * @return      The VersionData blob of the XLSX file.
     * @throws      StringException When the file extension is not 'xlsx'.
     */
    private static Blob validateXlsx(ContentVersion cv){
        if(cv?.FileExtension?.toLowerCase() != 'xlsx'){
            throw new StringException(FlowConstant.MSG_XLSX_EXTENSION_EXCEPTION);
        }
        return cv?.VersionData;
    }


    /**
     * @description Encapsulates the input parameters for converting an XLSX ContentDocument to LLM text.
     */
    global with sharing class Request {
        @InvocableVariable(label='ContentDocumentIds' description='List of content Document Ids, (only the first is used)' required=true)
        global Id[] contentDocumentIds;
    }


    /**
     * @description Encapsulates the outcome of the conversion, including success flag,
     *              optional error details, and the resulting LLM text payload.
     */
    global with sharing class Response {
        
        @InvocableVariable(label='Is Success'       description='True when the Apex Executed Successfully'             required=true)
        global Boolean isSuccess = false;
        
        @InvocableVariable(label='Error Message'    description='The error message in case Is Success = false'         required=false)
        global String errorMessage;

        @InvocableVariable(label='Worksheet Names'  description='The XLSX Data formatted in an LLM optimised format'   required=false)
        global FlowChoice[] worksheetNames;

        /**
         * @description Constructs a successful Response.
         * @param llmText The generated LLM-readable text derived from the XLSX file.
         */
        global Response(FlowChoice[] worksheetNames){
            this.isSuccess      = true;
            this.worksheetNames = worksheetNames;
        }

        /**
         * @description Constructs a failure Response.
         * @param isSuccess Unused input; the Response is forced to failure (false) within the constructor.
         * @param errorMessage The error message describing the failure.
         */
        global Response(Boolean isSuccess, String errorMessage){
            this.isSuccess      = false;
            this.errorMessage   = errorMessage;
        }
    }
}