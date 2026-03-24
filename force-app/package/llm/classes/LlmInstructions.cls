global with sharing class LlmInstructions {

   /**
     * @description Flow-invocable method to convert a ContentDocument to LLM text.
     * @param contentDocumentId The Id of the ContentDocument to process.
     * @return      The ContentVersion Body as text (placeholder) when file is .xlsx.
     * @throws      AuraHandledException if the Id is not a ContentDocument, the record isn't found,
     *              the user lacks access, or the file is not an .xlsx.
     */
    @InvocableMethod(label='Get Default XLSX to LLM Text Instructions' description='Gets the default instructions for the LLM on how to interpret the Converted XLSX LLM Text data format')
    public static Response[] getDefaultLlmTextInstructions(){
        try {
            return new Response[]{
                new Response(CommonUtil.getStaticResourceBody('llm_default_instructions'))
            };
        }catch(Exception e) { 
            return new Response[]{new Response(false,'An unexpected error occurred whilst creating the default LLM Instructions. Exception Message: ' + e.getMessage())};
        }
    }


    global with sharing class Response {
        
        @InvocableVariable(label='Is Success'       description='True when the Apex Executed Successfully'             required=true)
        global Boolean isSuccess = false;
        
        @InvocableVariable(label='Error Message'    description='The error message in case Is Success = false'         required=false)
        global String errorMessage;

        @InvocableVariable(label='LLM Instructions' description='The XLSX Data formatted in an LLM optimised format'   required=false)
        global String llmInstructions;

        /**
         * @description Default Constructor for success
         */
        global Response(String llmInstructions){
            this.isSuccess      = true;
            this.llmInstructions= llmInstructions;
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