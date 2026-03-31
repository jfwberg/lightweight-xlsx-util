@IsTest
private class LlmInstructionsTest {

    @IsTest
    static void testGetDefaultLlmTextInstructions() {
        
        Test.startTest();
        LlmInstructions.Response[] responses = LlmInstructions.getDefaultLlmTextInstructions();
        Test.stopTest();

        Assert.areEqual(
            CommonUtil.getStaticResourceBody(Constant.LLM_DEF_INSTRUCTION_SR), 
            responses[0].llmInstructions,
            'Unexpected default instructions'
        );
    }


    @IsTest
    static void testGetDefaultLlmTextInstructionsException() {
        
        Test.startTest();
        LlmInstructions.forceException = true;
        LlmInstructions.Response[] responses = LlmInstructions.getDefaultLlmTextInstructions();
        Test.stopTest();

        Assert.areEqual(
            String.format(Constant.MSG_LLM_TEXT_UNKNOWN_ERROR,new String[]{Constant.MSG_FORCED_EXCEPTION}),
            responses[0].errorMessage,
            'Unexpected exception message'
        );
    }
}