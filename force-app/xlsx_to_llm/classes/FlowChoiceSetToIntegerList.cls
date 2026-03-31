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
global with sharing class FlowChoiceSetToIntegerList {

    @InvocableMethod(label='Convert FlowChoice Set to Integer List' description='Takes an FlowChoise set and converts the values into an Integer List')
    global static Response[] convert(Request[] requests) {
        try {
            // Output List
            Integer[] integerList = new Integer[]{};

            // Convert each value to an integer and add it to the output
            for(String fc : requests[0].flowChoiceSet.split(';')){
                integerList.add(Integer.valueOf(fc?.trim()));
            }

            // Return the choices
            return new Response[]{new Response(integerList)};

        }catch(Exception e) {
            return new Response[]{new Response(false,String.format(FlowConstant.MSG_CHOICE_SET_TO_INTEGER_ERROR,new String[]{e.getMessage()}) )};
        }
    }
    

    /**
     * @description Encapsulates the input parameters for converting an XLSX ContentDocument to LLM text.
     */
    global with sharing class Request {
        @InvocableVariable(label='Flow Choice Set' description='The flow choice set to convert' required=true)
        global String flowChoiceSet;
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

        @InvocableVariable(label='Integer List'     description='The list of integers'                                  required=false)
        global Integer[] integerList;

        /**
         * @description Constructs a successful Response.
         * @param llmText The generated LLM-readable text derived from the XLSX file.
         */
        global Response(Integer[] integerList){
            this.isSuccess   = true;
            this.integerList = integerList;
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