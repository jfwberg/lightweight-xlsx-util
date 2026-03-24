
global with sharing class LlmText {
    /**
     * @description Flow-invocable method to convert a ContentDocument to LLM text.
     * @param contentDocumentId The Id of the ContentDocument to process.
     * @return      The ContentVersion Body as text (placeholder) when file is .xlsx.
     * @throws      AuraHandledException if the Id is not a ContentDocument, the record isn't found,
     *              the user lacks access, or the file is not an .xlsx.
     */
    @InvocableMethod(label='Convert XLSX ContentDocument to LLM Text' description='Takes an XLSX file (ContentDocument Id) as input and converts the data into LLM readable text')
    public static Response[] convertContentDocumentToLlmText(Request[] requests) {
        try {
            // Validate input using a helper method
            validateRequests(requests);
         
            // Set the additional (optional) values
            Boolean      includeDefaultInstructions = requests[0].includeDefaultInstructions ?? false;
            Set<Integer> selectedSheets             = requests[0].selectedSheets != null ? new Set<Integer>(requests[0].selectedSheets) : null;

            // Return a new success response
            return new Response[]{ 
                new Response(
                    ((includeDefaultInstructions) ? '[instructions]' : '' ) +
                    Parse.toLlmText(
                        new Compression.ZipReader(
                            validateXlsx([
                            SELECT FileExtension, VersionData FROM ContentVersion
                            WHERE ContentDocumentId = :requests[0].contentDocumentId 
                            AND IsLatest = true 
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                            ][0])
                        )?.getEntriesMap(),
                        selectedSheets
                    )
                )
            };
        }catch(QueryException qe) {
            return new Response[]{new Response(false,'The current user does not have access to the Content Document or the Content Document Id is invalid')};
        }catch(Exception e) {
            return new Response[]{new Response(false,'An unexpected error occurred whilst processing the ContentDocument. Exception Message: ' + e.getMessage())};
        }
    }
    

    private static void validateRequests(Request[] requests){
        
        // Validate we have some requests coming in
        if(requests.isEmpty()){
            throw new StringException('Invalid input: The requests parameter cannot be empty.');
        }
    
        // Validate the request input
        if (requests[0].contentDocumentId == null) {
            throw new StringException('A ContentDocumentId is required.');
        }

        // Validate SObject type using getSObjectType() to ensure proper type checking
        if (requests[0].contentDocumentId.getSObjectType() != ContentDocument.SObjectType) {
            throw new StringException('The provided Content Document Id is invalid.');
        }
    }


    /**
     * @description Helper method to optimize file memory
     * @param cv    The ContentVersion record from a query
     * @return      The body content of the content version
     * @throws      StringException when there is an invalid extension
     */
    private static Blob validateXlsx(ContentVersion cv){
        if(cv?.FileExtension?.toLowerCase() != 'xlsx'){
            throw new StringException('The content document extension is invalid. Only the "xlsx" extension is supported');
        }
        return cv?.VersionData;
    }


    global with sharing class Request {
    
        @InvocableVariable(label='Content Document Id' description='The Id of the XLSX ContentDocument' required=true)
        global Id        contentDocumentId;

        @InvocableVariable(label='Include Default Instructions' description='Select this if you want the default instructions on how the LLM should interpret the data included in the prompt' required=false)
        global Boolean   includeDefaultInstructions = false;

        @InvocableVariable(label='Selected Sheets' description='A list of sheets to be included. Use the 0 indexes if you know the sheet numbers' required=false)
        global Integer[] selectedSheets;

        @InvocableVariable(label='Use DomDoc for Parsing(Advanced)' description='Use the Apex DomDoc Class for parsing rather than the XmlStreamReader (Advanced)' required=false)
        global Boolean   useDomDoc                  = false;

    }


    global with sharing class Response {
        
        @InvocableVariable(label='Is Success'    description='True when the Apex Executed Successfully'             required=true)
        global Boolean isSuccess = false;
        
        @InvocableVariable(label='Error Message' description='The error message in case Is Success = false'         required=false)
        global String errorMessage;

        @InvocableVariable(label='LLM Text'      description='The XLSX Data formatted in an LLM optimised format'   required=false)
        global String llmText;

        /**
         * @description Default Constructor for success
         */
        global Response(String llmText){
            this.isSuccess = true;
            this.llmText   = llmText;
        }

        /**
         * @description Error message constructor
         */
        global Response(Boolean isSuccess, String errorMessage){
            this.isSuccess      = false;
            this.errorMessage   = errorMessage;
        }
    }
}