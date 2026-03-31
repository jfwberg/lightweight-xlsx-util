@IsTest
private with sharing class FlowTest {
    
    @IsTest
    static void testgetAll() {
        
        // Create a new builder with a few sheets an cells
        xlsx.Builder b = new xlsx.Builder();
        b.addTextCell(0, 0, 0, 'Value A1');
        b.addTextCell(1, 1, 1, 'Value B2');
        
        // Create the blob
        ContentVersion cv = new ContentVersion();
        cv.Title          = 'XLSX Test';
        cv.PathOnClient   = 'test.xlsx';
        cv.VersionData    = xlsx.Build.asBlob(b);
        insert cv;

        // Create new request
        FlowWorksheetList.Request request = new FlowWorksheetList.Request();
        request.contentDocumentIds = new Id[]{[SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId};
        FlowWorksheetList.Request[] requests = new FlowWorksheetList.Request[]{request};
        
        FlowWorksheetList.Response[] results;
        
        Test.startTest();
        results = FlowWorksheetList.getAll(requests);
        Test.stopTest();

        Assert.areEqual(
            2,
            results[0].worksheetNames.size(),
            'Unexpected number of sheets'
        );
    }

    @IsTest
    static void testgetAllExceptions() {
       
        // Create new request
        FlowWorksheetList.Request request    = new FlowWorksheetList.Request();
        request.contentDocumentIds = new Id[]{'069Ae000006ZpCHIA0'};
        FlowWorksheetList.Request[] requests = new FlowWorksheetList.Request[]{request};
        FlowWorksheetList.Response[] results;
        
        Test.startTest();
       
        // Test validation non existing
        results = FlowWorksheetList.getAll(requests);
        Assert.areEqual(false, results[0].isSuccess);
        
        // Test Validation
        results = FlowWorksheetList.getAll(null);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = null;
        results = FlowWorksheetList.getAll(requests);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = new Id[]{};
        results = FlowWorksheetList.getAll(requests);
        Assert.areEqual(false, results[0].isSuccess);

        // Test validation
        request.contentDocumentIds  = new Id[]{null};
        results = FlowWorksheetList.getAll(requests);
        Assert.areEqual(false, results[0].isSuccess);
        
        // Test validation
        request.contentDocumentIds  = new Id[]{UserInfo.getUserId()};
        results = FlowWorksheetList.getAll(requests);
        Assert.areEqual(false, results[0].isSuccess);
        
        Test.stopTest();
    }


    @IsTest
    static void testConvert() {
        

        // Create new request
        FlowChoiceSetToIntegerList.Request request = new FlowChoiceSetToIntegerList.Request();
        request.flowChoiceSet = '1;2;3';
        FlowChoiceSetToIntegerList.Request[] requests = new FlowChoiceSetToIntegerList.Request[]{request};
        
        FlowChoiceSetToIntegerList.Response[] results;

        Test.startTest();
        results = FlowChoiceSetToIntegerList.convert(requests);
        Test.stopTest();
        

    }

    @IsTest
    static void testConvertExceptions() {
        
        // Create new request
        FlowChoiceSetToIntegerList.Request request = new FlowChoiceSetToIntegerList.Request();
        request.flowChoiceSet = 'ABC;;DEF';
        FlowChoiceSetToIntegerList.Request[] requests = new FlowChoiceSetToIntegerList.Request[]{request};
        
        FlowChoiceSetToIntegerList.Response[] results;


        Test.startTest();
        results = FlowChoiceSetToIntegerList.convert(requests);
        Test.stopTest();

        
        Assert.areEqual(
            false,
            results[0].isSuccess,
            'Unexpected exception message'
        );
        
    }
}