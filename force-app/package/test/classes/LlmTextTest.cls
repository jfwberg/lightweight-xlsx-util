@IsTest
private class LlmTextTest {

    @IsTest
    static void testGetAll() {
        
        // Create a new builder with a few sheets an cells
        Builder b = new Builder();
        b.addTextCell(0, 0, 0, 'Value A1');
        b.addTextCell(1, 1, 1, 'Value B2');
        
        // Create the blob
        ContentVersion cv = new ContentVersion();
        cv.Title          = 'XLSX Test';
        cv.PathOnClient   = 'test.xlsx';
        cv.VersionData    = Build.asBlob(b);
        insert cv;

        // Create new request
        LlmText.Request request = new LlmText.Request();
        request.contentDocumentIds = new Id[]{[SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId};
        LlmText.Request[] requests = new LlmText.Request[]{request};
        
        LlmText.Response[] results;
        
        Test.startTest();
        results = LlmText.convertContentDocumentToLlmText(requests);
        Test.stopTest();

        Assert.areEqual(
            'SHEET=Sheet1\nR1^C1=Value A1\nSHEET=Sheet2\nR2^C2=Value B2',
            results[0].llmText,
            'Unexpected LLM Response'
        );
    }


    @IsTest
    static void testGetAllExceptions() {
        
       
        // Create new request
        LlmText.Request request    = new LlmText.Request();
        request.contentDocumentIds  = new Id[]{'069Ae000006ZpCHIA0'};
        LlmText.Request[] requests = new LlmText.Request[]{request};
        LlmText.Response[] results;
        
        Test.startTest();
       
        // Test validation non existing
        results = LlmText.convertContentDocumentToLlmText(requests);
        Assert.areEqual(false, results[0].isSuccess);
        
        // Test Validation
        results = LlmText.convertContentDocumentToLlmText(null);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = null;
        results = LlmText.convertContentDocumentToLlmText(requests);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = new Id[]{};
        results = LlmText.convertContentDocumentToLlmText(requests);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = new Id[]{null};
        results = LlmText.convertContentDocumentToLlmText(requests);
        Assert.areEqual(false, results[0].isSuccess);
        
        // Test validation
        request.contentDocumentIds  = new Id[]{UserInfo.getUserId()};
        results = LlmText.convertContentDocumentToLlmText(requests);
        Assert.areEqual(false, results[0].isSuccess);
        

        Test.stopTest();
    }
       
        
    

}