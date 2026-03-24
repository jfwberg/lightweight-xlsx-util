/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the Parse and Build classes
 * @tests          Parse
 *                 Build
 */
@IsTest
@SuppressWarnings('PMD.OneDeclarationPerLine')
private with sharing class ParseTest {

    /** **************************************************************************************************** **
     **                                       GLOBAL WORKSHEET METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Test Method for the worksheet name to index logic
     */
    @IsTest
    private static void testToWorksheetNameIndexMap(){

        // Create a basic file with 2 worksheets
        Builder b = new Builder();
        b.addWorksheet('Worksheet 01');
        b.addWorksheet('Worksheet 02');
        
        // Build the archive as document and content version
        Blob documentData       = Build.asDocument(b).body;
        Blob contentVersionData = Build.asContentVersion(b).VersionData;

        Test.startTest();
        Map<String,Integer> indexMap1 = Parse.toWorksheetNameIndexMap(new Compression.ZipReader(documentData).getEntriesMap());
        Map<String,Integer> indexMap2 = Parse.toWorksheetNameIndexMap(new Compression.ZipReader(contentVersionData).getEntriesMap());
        Test.stopTest();

        // Assert the indexes are correct
        Assert.areEqual(0, indexMap1.get('Worksheet 01'), 'Unexpected sheet name');
        Assert.areEqual(1, indexMap1.get('Worksheet 02'), 'Unexpected sheet name');
        Assert.areEqual(0, indexMap2.get('Worksheet 01'), 'Unexpected sheet name');
        Assert.areEqual(1, indexMap2.get('Worksheet 02'), 'Unexpected sheet name');
    }

    
    /**
     * @description Test Method for the worksheet name to index logic exception
     */
    @IsTest
    private static void testToWorksheetNameIndexMapException(){
        
        // Create invalid archive
        Compression.ZipWriter zw = new Compression.ZipWriter();
        zw.addEntry('invalid.txt', Blob.valueOf('Some text'));
        Blob archive = zw.getArchive();
        
        // Run the test
        try{
            Parse.toWorksheetNameIndexMap(new Compression.ZipReader(archive).getEntriesMap());
            throw new TestException(TestUtil.EXCEPTION_SAFEGUARD_MESSAGE);
        } catch(ParseException e){
            Assert.AreEqual(
                String.format(Constant.MSG_INVALID_ZIP_ENTRY, new String[]{Constant.ZP_PATH_WORKBOOK}),
                e.getMessage(),
                TestUtil.EXCEPTION_ASSERTION_MESSAGE
            );
        }
    }


    /**
     * @description Test Method for the worksheet index to name logic
     */
    @IsTest
    private static void testToWorksheetIndexNameMap(){

        // Create a basic file with 2 worksheets
        Builder b = new Builder();
        b.addWorksheet('Worksheet 01');
        b.addWorksheet('Worksheet 02');
        
        // Build the archive as document and content version
        Blob documentData       = Build.asDocument(b).body;
        Blob contentVersionData = Build.asContentVersion(b).VersionData;

        Test.startTest();
        Map<Integer,String> indexMap1 = Parse.toWorksheetIndexNameMap(new Compression.ZipReader(documentData).getEntriesMap());
        
        // Only select the second sheet
        Map<Integer,String> indexMap2 = Parse.toWorksheetIndexNameMap(new Compression.ZipReader(contentVersionData).getEntriesMap(), new Set<Integer>{1});
        Test.stopTest();

        // Assert the indexes are correct
        Assert.areEqual(indexMap1.get(0), 'Worksheet 01', 'Unexpected sheet index');
        Assert.areEqual(indexMap1.get(1), 'Worksheet 02', 'Unexpected sheet index');
        
        // The second sheet is selected and should have index 0 as it is the only one
        Assert.areEqual(indexMap2.get(0), 'Worksheet 02', 'Unexpected sheet index');
    }


    /** **************************************************************************************************** **
     **                                         GLOBAL ARRAY METHODS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Test Method for the toArray logic
     */
    @IsTest
    private static void testToArray() {
        
        // Create a new builder
        Builder b = new Builder();

        // Create a builder that does output the dimension element
        Builder noDimensionBuilder = new Builder();
        noDimensionBuilder.addWorksheet('Worksheet 01', false);
        noDimensionBuilder.addWorksheet('Worksheet 02', false);
        noDimensionBuilder.addWorksheet('Worksheet 03', false);
        
        // Create the test data
        populateWorksheets(b);
        populateWorksheets(noDimensionBuilder);
        
        // Execute the tests
        Test.startTest();
        Object[][][] documentResult                     = Parse.toArray(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResult               = Parse.toArray(
                                                            new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

        Object[][][] documentResultDomDoc               = Parse.toArrayDomDoc(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultDomDoc         = Parse.toArrayDomDoc(
                                                            new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );
        
        Object[][][] documentResultIv                   = Parse.toArrayInverted(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultIv             = Parse.toArrayInverted(
                                                            new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

        Object[][][] documentResultDomDocIv             = Parse.toArrayInvertedDomDoc(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultDomDocIv       = Parse.toArrayInvertedDomDoc(
                                                            new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

       Object[][][] documentResultNd                    = Parse.toArray(
                                                            new Compression.ZipReader(Build.asDocument(noDimensionBuilder).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultNd             = Parse.toArray(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

        Object[][][] documentResultDomDocNd             = Parse.toArrayDomDoc(
                                                            new Compression.ZipReader(Build.asDocument(noDimensionBuilder).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultDomDocNd       = Parse.toArrayDomDoc(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );
        
        Object[][][] documentResultIvNd                 = Parse.toArrayInverted(
                                                            new Compression.ZipReader(Build.asDocument(noDimensionBuilder).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultIvNd           = Parse.toArrayInverted(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

        Object[][][] documentResultDomDocIvNd           = Parse.toArrayInvertedDomDoc(
                                                            new Compression.ZipReader(Build.asDocument(noDimensionBuilder).body).getEntriesMap()
                                                        );

        Object[][][] contentVersionResultDomDocIvNd     = Parse.toArrayInvertedDomDoc(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );    
               
        // Additional formatting (reuses logic so requires less tests)
        Map<String,Object[][]> arrayMapResult01         = Parse.toSheetNameArrayMap(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Map<String,Object[][]> arrayMapResult02         = Parse.toSheetNameArrayMap(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );
        Map<String,Object[][]> arrayMapResultIv01       = Parse.toSheetNameArrayInvertedMap(
                                                            new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                        );

        Map<String,Object[][]> arrayMapResultIv02       = Parse.toSheetNameArrayInvertedMap(
                                                            new Compression.ZipReader(Build.asContentVersion(noDimensionBuilder).VersionData).getEntriesMap(),
                                                            new Set<Integer>{0,2}
                                                        );

        Test.stopTest();

        // Validate we have the correct number of worksheets
        Assert.areEqual(3,documentResult.size(),                'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResult.size(),          'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultDomDoc.size(),          'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultDomDoc.size(),    'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultIv.size(),              'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultIv.size(),        'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultDomDocIv.size(),        'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultDomDocIv.size(),  'Unexpected number of worksheets');

        // Validate we have the correct number of worksheets for sheets without a dimension
        Assert.areEqual(3,documentResultNd.size(),              'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultNd.size(),              'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultNd.size(),        'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultDomDocNd.size(),        'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultDomDocNd.size(),  'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultIvNd.size(),            'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultIvNd.size(),      'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultDomDocIvNd.size(),      'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultDomDocIvNd.size(),'Unexpected number of worksheets');

        // Validate additional formatting (reuses logic)
        Assert.areEqual(3,arrayMapResult01.size(),              'Unexpected number of worksheets');
        Assert.areEqual(2,arrayMapResult02.size(),              'Unexpected number of worksheets');
        Assert.areEqual(3,arrayMapResultIv01.size(),            'Unexpected number of worksheets');
        Assert.areEqual(2,arrayMapResultIv02.size(),            'Unexpected number of worksheets');



        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResult.size(); i < max; i++) {
            validateCellValuesInArray(documentResult[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResult.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResult[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultDomDoc.size(); i < max; i++) {
            validateCellValuesInArray(documentResultDomDoc[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultDomDoc.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultDomDoc[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultIv.size(); i < max; i++) {
            validateCellValuesInArray(documentResultIv[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultIv.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultIv[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultDomDocIv.size(); i < max; i++) {
            validateCellValuesInArray(documentResultDomDocIv[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultDomDocIv.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultDomDocIv[i]);
        }
        
        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultNd.size(); i < max; i++) {
            validateCellValuesInArray(documentResultNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultNd.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultDomDocNd.size(); i < max; i++) {
            validateCellValuesInArray(documentResultDomDocNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultDomDocNd.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultDomDocNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultIvNd.size(); i < max; i++) {
            validateCellValuesInArray(documentResultIvNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultIvNd.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultIvNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultDomDocIvNd.size(); i < max; i++) {
            validateCellValuesInArray(documentResultDomDocIvNd[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultDomDocIvNd.size(); i < max; i++) {
            validateCellValuesInArray(contentVersionResultDomDocIvNd[i]);
        }
    }


    /** **************************************************************************************************** **
     **                                          GLOBAL MAP METHODS                                          **
     ** **************************************************************************************************** **/
    /**
     * @description Test Method for the toMap logic
     */
    @IsTest
    private static void testToMap() {
        
        // Create a new builder
        Builder b = new Builder();
        
        // Test that the keywords get cropped at 255 characters
        for (Integer i = 0; i < 30; i++) {
            b.addKeyword('1234567890');
        }
        
        // Create the test data
        populateWorksheets(b);
        
        // Execute the tests
        Test.startTest();
        List<Map<String,Object>> documentResult             = Parse.toMap(
                                                                new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                            );

        List<Map<String,Object>> contentVersionResult       = Parse.toMap(
                                                                new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                                new Set<Integer>{0,2}
                                                            );

        List<Map<String,Object>> documentResultDomDoc       = Parse.toMapDomDoc(
                                                                new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                            );

        List<Map<String,Object>> contentVersionResultDomDoc = Parse.toMapDomDoc(
                                                                new Compression.ZipReader(Build.asContentVersion(b).VersionData).getEntriesMap(),
                                                                new Set<Integer>{0,2}
                                                            );
        Test.stopTest();

        // Validate we have the correct number of worksheets
        Assert.areEqual(3,documentResult.size(),             'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResult.size(),       'Unexpected number of worksheets');
        Assert.areEqual(3,documentResultDomDoc.size(),       'Unexpected number of worksheets');
        Assert.areEqual(2,contentVersionResultDomDoc.size(), 'Unexpected number of worksheets');

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResult.size(); i < max; i++) {
            validateCellValuesInMap(documentResult[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResult.size(); i < max; i++) {
            validateCellValuesInMap(contentVersionResult[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=documentResultDomDoc.size(); i < max; i++) {
            validateCellValuesInMap(documentResultDomDoc[i]);
        }

        // Iterate all worksheets in all results and validate their output
        for (Integer i = 0, max=contentVersionResultDomDoc.size(); i < max; i++) {
            validateCellValuesInMap(contentVersionResultDomDoc[i]);
        } 
    }


    /** **************************************************************************************************** **
     **                                        GLOBAL LLM TEXT METHODS                                       **
     ** **************************************************************************************************** **/
    @IsTest
    private static void testToLlmText(){

    }

    
    /** **************************************************************************************************** **
     **                                             OTHER METHODS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Test Method for the inline strings logic
     */
    @IsTest
    private static void testInlineStrings() {
        
        // Create a new builder
        Builder b = new Builder();
        
        // Use inline strings
        b.setUseSharedStrings(false);
        b.addTextCell(0, 0, 0, 'Lalalalala');
        
        // Execute the tests
        Test.startTest();

        Object[][][]             arrayResult    = Parse.toArrayDomDoc(
                                                    new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                );

        Object[][][]             arrayResultIv  = Parse.toArrayInvertedDomDoc(
                                                    new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                );

        List<Map<String,Object>> mapResult      = Parse.toMapDomDoc(
                                                    new Compression.ZipReader(Build.asDocument(b).body).getEntriesMap()
                                                );
        Test.stopTest();

        // Validate we have the correct number of worksheets
        Assert.areEqual(1, arrayResult.size(),   'Unexpected number of worksheets');
        Assert.areEqual(1, arrayResultIv.size(), 'Unexpected number of worksheets');
        Assert.areEqual(1, mapResult.size(),     'Unexpected number of worksheets');
        
        // Validate cell values
        Assert.areEqual('Lalalalala',   arrayResult[0][0][0].toString(),   'Unexpected Cell value');
        Assert.areEqual('Lalalalala',   mapResult[0].get('A1').toString(), 'Unexpected Cell value');
    }


    /** **************************************************************************************************** **
     **                              PRIVATE SUPPORT METHODS (CLASS SPECIFIC)                                **
     ** **************************************************************************************************** **/
    /**
     * @description Method to created worksheet test data
     * @param b The XLSX builder class instance
     */
    private static void populateWorksheets(Builder b){
        for (Integer i = 0; i < 3; i++) {
            b.addTextCell(   i, 0, 0, 'A1'     );
            b.addTextCell(   i, 1, 1, 'B2',   0);
            b.addNumberCell( i, 2, 2, 123.45   );
            b.addNumberCell( i, 3, 3, 678.90, 0);
            b.addNumberCell( i, 4, 4, 100      );
            b.addNumberCell( i, 5, 5, 200,    0);
            b.addBooleanCell(i, 6, 6, true     );
            b.addBooleanCell(i, 7, 7, false,  0);
            b.addFormulaCell(i, 8, 8, 19,     '=SUM(9,10)'   );
            b.addFormulaCell(i, 9, 9, 20,     '=SUM(10,10)',0);
        }
    }


    /**
     * @description method to validate cell values for multiple worksheets
     * @param worksheet The rows and cells array for a specific worksheet
     */
    private static void validateCellValuesInArray(Object[][] worksheet){
        
        // Validate the number of values
        Assert.areEqual(10, worksheet.size(),'Unexpected number of rows in worksheet');

        // Validate each individual values
        Assert.areEqual('A1',   String.valueOf( worksheet[0][0]), 'Unexpected Cell value');
        Assert.areEqual('B2',   String.valueOf( worksheet[1][1]), 'Unexpected Cell value');
        Assert.areEqual(123.45, Double.valueOf( worksheet[2][2]), 'Unexpected Cell value');
        Assert.areEqual(678.90, Double.valueOf( worksheet[3][3]), 'Unexpected Cell value');
        Assert.areEqual(100,    Integer.valueOf(worksheet[4][4]), 'Unexpected Cell value');
        Assert.areEqual(200,    Integer.valueOf(worksheet[5][5]), 'Unexpected Cell value');
        Assert.areEqual(true,   Boolean.valueOf(worksheet[6][6]), 'Unexpected Cell value');
        Assert.areEqual(false,  Boolean.valueOf(worksheet[7][7]), 'Unexpected Cell value');
        Assert.areEqual(19,     Integer.valueOf(worksheet[8][8]), 'Unexpected Cell value');
        Assert.areEqual(20,     Integer.valueOf(worksheet[9][9]), 'Unexpected Cell value');
    }


    /**
     * @description method to validate cell values for multiple worksheets
     * @param worksheet The rows and cells array for a specific worksheet
     */
    private static void validateCellValuesInMap(Map<String,Object> worksheet){
        
        // Validate the number of values
        Assert.areEqual(10, worksheet.size(),'Unexpected number of rows in worksheet');

        // Validate each individual values
        Assert.areEqual('A1',   String.valueOf( worksheet.get('A1' )), 'Unexpected Cell value');
        Assert.areEqual('B2',   String.valueOf( worksheet.get('B2' )), 'Unexpected Cell value');
        Assert.areEqual(123.45, Double.valueOf( worksheet.get('C3' )), 'Unexpected Cell value');
        Assert.areEqual(678.90, Double.valueOf( worksheet.get('D4' )), 'Unexpected Cell value');
        Assert.areEqual(100,    Integer.valueOf(worksheet.get('E5' )), 'Unexpected Cell value');
        Assert.areEqual(200,    Integer.valueOf(worksheet.get('F6' )), 'Unexpected Cell value');
        Assert.areEqual(true,   Boolean.valueOf(worksheet.get('G7' )), 'Unexpected Cell value');
        Assert.areEqual(false,  Boolean.valueOf(worksheet.get('H8' )), 'Unexpected Cell value');
        Assert.areEqual(19,     Integer.valueOf(worksheet.get('I9' )), 'Unexpected Cell value');
        Assert.areEqual(20,     Integer.valueOf(worksheet.get('J10')), 'Unexpected Cell value');
    }
}