/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Provides Flow-invocable utilities for generating default Large Language Model (LLM)
 *                 parsing instructions used to interpret converted XLSX content as plain text.
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LlmInstructions {

    // Test variable to achieve code coverage
    @TestVisible private static Boolean forceException = false;

    /**
     * @description Returns default instructions for how the LLM should interpret the Converted XLSX LLM Text data format.
     * @return An array containing a single Response instance. When successful, Response.isSuccess=true and
     *         Response.llmInstructions contains the default instruction text. When an unexpected error occurs,
     *         a single Response is returned with isSuccess=false and errorMessage populated.
     * @throws  Exception Propagated runtime exceptions are caught internally; the method returns a failure Response instead of throwing.
     */
    @InvocableMethod(label='Get Default XLSX to LLM Text Instructions' description='Gets the default instructions for the LLM on how to interpret the Converted XLSX LLM Text data format')
    global static Response[] getDefaultLlmTextInstructions(){
        try {
            if(forceException){
                throw new StringException(Constant.MSG_FORCED_EXCEPTION);
            }
            
            return new Response[]{
                new Response(CommonUtil.getStaticResourceBody(Constant.LLM_DEF_INSTRUCTION_SR))
            };
        }catch(Exception e) { 
            return new Response[]{new Response(false,String.format(Constant.MSG_LLM_TEXT_UNKNOWN_ERROR,new String[]{e.getMessage()}))};
        }
    }


    
    /**
     * @description Encapsulates the result of generating LLM instructions, including success flag,
     *              error message (if any), and the instruction payload.
     */
    global with sharing class Response {
        
        @InvocableVariable(label='Is Success'       description='True when the Apex Executed Successfully'             required=true)
        global Boolean isSuccess = false;
        
        @InvocableVariable(label='Error Message'    description='The error message in case Is Success = false'         required=false)
        global String errorMessage;

        @InvocableVariable(label='LLM Instructions' description='The XLSX Data formatted in an LLM optimised format'   required=false)
        global String llmInstructions;

        /**
         * @description Constructs a successful Response.
         * @param llmInstructions The generated default instructions text for the LLM.
         */
        global Response(String llmInstructions){
            this.isSuccess      = true;
            this.llmInstructions= llmInstructions;
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