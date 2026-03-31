/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Provides a Flow-invocable utility to convert XLSX ContentDocument data into
 *                 LLM-readable plain text, with optional inclusion of default interpretation instructions.
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LlmText {

    /**
     * @description Converts the latest ContentVersion of the provided ContentDocument into LLM-readable text.
     *              Optionally prefixes default interpretation instructions based on the request.
     * @param requests A single-element array containing the Request with ContentDocumentId and options.
     * @return      An array with a single Response. On success, Response.isSuccess=true and Response.llmText contains the output.
     *              On failure, returns a single Response with isSuccess=false and errorMessage populated.
     * @throws      StringException Thrown when requests is empty, ContentDocumentId is missing/invalid, or file extension is not xlsx.
     * @throws      QueryException  Thrown if the current user lacks access or the ContentDocumentId is invalid.
     */
    @InvocableMethod(label='Convert XLSX ContentDocument to LLM Text' description='Takes an XLSX file (ContentDocument Id) as input and converts the data into LLM readable text')
    global static Response[] convertContentDocumentToLlmText(Request[] requests) {
        try {
            // Validate input using a helper method
            validateRequests(requests);
         
            // Set the additional (optional) values
            Boolean      useDomDoc                  = requests[0].useDomDoc                  ?? false;
            Boolean      includeDefaultInstructions = requests[0].includeDefaultInstructions ?? false;
            Set<Integer> selectedSheets             = requests[0].selectedSheets != null ? new Set<Integer>(requests[0].selectedSheets) : null;

            // Return a new success response
            return new Response[]{ 
                new Response(
                    ((includeDefaultInstructions) ? CommonUtil.getStaticResourceBody(Constant.LLM_DEF_INSTRUCTION_SR) : '' ) +
                    ((useDomDoc) ?
                    Parse.toLlmTextDomDoc(
                        new Compression.ZipReader(
                            validateXlsx([
                            SELECT FileExtension, VersionData FROM ContentVersion
                            WHERE ContentDocumentId = :requests[0].contentDocumentIds[0] 
                            AND IsLatest = true 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                            ][0])
                        )?.getEntriesMap(),
                        selectedSheets
                    ) :
                    Parse.toLlmText(
                        new Compression.ZipReader(
                            validateXlsx([
                            SELECT FileExtension, VersionData FROM ContentVersion
                            WHERE ContentDocumentId = :requests[0].contentDocumentIds[0] 
                            AND IsLatest = true 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                            ][0])
                        )?.getEntriesMap(),
                        selectedSheets
                    ))
                )
            };
        }catch(Exception e) {
            return new Response[]{new Response(false,String.format(Constant.MSG_LLM_TEXT_UNKNOWN_ERROR,new String[]{e.getMessage()}) )};
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
            throw new StringException('Invalid input: The requests parameter cannot be empty.');
        }
    
        // Validate the request input
        if (requests[0].contentDocumentIds[0] == null){
            throw new StringException('A ContentDocumentId is required.');
        }

        // Validate SObject type using getSObjectType() to ensure proper type checking
        if (requests[0].contentDocumentIds[0].getSObjectType() != ContentDocument.SObjectType) {
            throw new StringException('The provided Content Document Id is invalid.');
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
            throw new StringException(Constant.MSG_XLSX_EXTENSION_EXCEPTION);
        }
        return cv?.VersionData;
    }


    /**
     * @description Encapsulates the input parameters for converting an XLSX ContentDocument to LLM text.
     */
    global with sharing class Request {
    
        @InvocableVariable(label='Content Document Id' description='The Id of the XLSX ContentDocument' required=true)
        global Id[]      contentDocumentIds;

        @InvocableVariable(label='Include Default Instructions' description='Select this if you want the default instructions on how the LLM should interpret the data included in the prompt' required=false)
        global Boolean   includeDefaultInstructions = false;

        @InvocableVariable(label='Selected Sheets' description='A list of sheets to be included. Use the 0 indexes if you know the sheet numbers' required=false)
        global Integer[] selectedSheets;

        @InvocableVariable(label='Use DomDoc for Parsing(Advanced)' description='Use the Apex DomDoc Class for parsing rather than the XmlStreamReader (Advanced)' required=false)
        global Boolean   useDomDoc                  = false;

    }


    /**
     * @description Encapsulates the outcome of the conversion, including success flag,
     *              optional error details, and the resulting LLM text payload.
     */
    global with sharing class Response {
        
        @InvocableVariable(label='Is Success'    description='True when the Apex Executed Successfully'             required=true)
        global Boolean isSuccess = false;
        
        @InvocableVariable(label='Error Message' description='The error message in case Is Success = false'         required=false)
        global String errorMessage;

        @InvocableVariable(label='LLM Text'      description='The XLSX Data formatted in an LLM optimised format'   required=false)
        global String llmText;

        /**
         * @description Constructs a successful Response.
         * @param llmText The generated LLM-readable text derived from the XLSX file.
         */
        global Response(String llmText){
            this.isSuccess = true;
            this.llmText   = llmText;
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