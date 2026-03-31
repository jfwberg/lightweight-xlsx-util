/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the build utilities
 * @Tests          BuildUtil
 * 
 */
@IsTest
private class BuildUtilTest {

    @IsTest
    static void testPopulateColumnAndRowNames(){
        
        // Run tests
        Test.startTest();
        BuildUtil.populateColumnAndRowNames(8,8);
        Test.stopTest();
        
        // Assert test values
        Assert.areEqual(
            BuildUtil.columnNames,
            new List<String>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'},
            'Column Names don\'t match'
        );

        Assert.areEqual(
            BuildUtil.rowNames,
            new List<String>{'1', '2', '3', '4', '5', '6', '7', '8','9'},
            'Row Names don\'t match'
        );
    }


    @IsTest
    private static void testGetCellName() {
        
        // Run tests
        Test.startTest();
        BuildUtil.populateColumnAndRowNames(999,999);
        Test.stopTest();

        // Assert test values
        Assert.areEqual('A1',      BuildUtil.getCellName(  0,   0), 'Expected cell name to be "A1"'     );
        Assert.areEqual('E4',      BuildUtil.getCellName(  4,   3), 'Expected cell name to be "E4"'     );
        Assert.areEqual('ALL1000', BuildUtil.getCellName(999, 999), 'Expected cell name to be "ALL1000"');
    }


    @IsTest
    private static void testGetCellRange() {
        // Run tests
        Test.startTest();
        BuildUtil.populateColumnAndRowNames(999,999);
        Test.stopTest();
        
       // Assert test values
        Assert.areEqual('C1:F4',      BuildUtil.getCellRange(2, 0, 5, 3),     'Expected cell range "C1:F4" not found'     );
        Assert.areEqual('A1:ALL1000', BuildUtil.getCellRange(0, 0, 999, 999), 'Expected cell range "A1:ALL1000" not found');
    }


    @IsTest
    static void testWriteSingleXmlElement() {
        
        // Run tests
        Test.startTest();
        XmlStreamWriter xsw1 = new XmlStreamWriter();
        XmlStreamWriter xsw2 = new XmlStreamWriter();
        BuildUtil.writeSingleXmlElement(xsw1, 'emtx2', 'worksheet', 'ABC');
        BuildUtil.writeSingleXmlElement(xsw2, null,    'workbook',  'DEF');
        Test.stopTest();
        
        // Assert test values
        Assert.areEqual('<emtx2:worksheet>ABC</emtx2:worksheet>', xsw1.getXmlString(), 'Unexpected XML String');
        Assert.areEqual('<workbook>DEF</workbook>',               xsw2.getXmlString(), 'Unexpected XML String');
    }


    @IsTest
    private static void testWriteSingleXmlElementWithChildren(){
    
        // Run the tests
        test.startTest();

        // Create the column and row index
        BuildUtil.populateColumnAndRowNames(3,3);

        // Create a parent element
        XmlElement.Cols parentElement = new XmlElement.Cols();
        
        // Create some child elements in a list
        parentElement.cols.add(new XmlElement.Col(0));
        parentElement.cols.add(new XmlElement.Col(1));
        parentElement.cols.add(new XmlElement.Col(2));

        // Streamwriter + test logic
        XmlStreamWriter xsw1 = new XmlStreamWriter();
        XmlStreamWriter xsw2 = new XmlStreamWriter();
        XmlStreamWriter xsw3 = new XmlStreamWriter();
        BuildUtil.writeSingleXmlElementWithChildren(xsw1, null, 'cols', parentElement.cols);
        BuildUtil.writeSingleXmlElementWithChildren(xsw2, 'ns', 'cols', parentElement.cols);
        BuildUtil.writeSingleXmlElementWithChildren(xsw3, 'ns', 'cols', null);
        Test.stopTest();
        
        // Assert
        Assert.areEqual(
            '<cols><col min="1" max="1" width="8.11"/><col min="2" max="2" width="8.11"/><col min="3" max="3" width="8.11"/></cols>',
            xsw1.getXmlString(),
            'Unexpected XML String'
        );

        // Assert
        Assert.areEqual(
            '<ns:cols><col min="1" max="1" width="8.11"/><col min="2" max="2" width="8.11"/><col min="3" max="3" width="8.11"/></ns:cols>',
            xsw2.getXmlString(),
            'Unexpected XML String'
        );

        // Assert when it needs to be skipped
        Assert.areEqual(
            '',
            xsw3.getXmlString(),
            'Unexpected XML String'
        );
    }


    @IsTest
    private static void testWriteSingleXmlElementWithChildrenAndDefaultNamespace(){
    
        // Run the tests
        test.startTest();

        // Create the column and row index
        BuildUtil.populateColumnAndRowNames(3,3);

        // Create a parent element
        XmlElement.Cols parentElement = new XmlElement.Cols();
        
        // Create some child elements in a list
        parentElement.cols.add(new XmlElement.Col(0));
        parentElement.cols.add(new XmlElement.Col(1));
        parentElement.cols.add(new XmlElement.Col(2));

        // Streamwriter + test logic
        XmlStreamWriter xsw1 = new XmlStreamWriter();
        XmlStreamWriter xsw2 = new XmlStreamWriter();
        XmlStreamWriter xsw3 = new XmlStreamWriter();
        BuildUtil.writeSingleXmlElementWithChildrenAndDefaultNamespace(xsw1, null, 'cols', parentElement.cols, 'dns');
        BuildUtil.writeSingleXmlElementWithChildrenAndDefaultNamespace(xsw2, 'ns', 'cols', parentElement.cols, 'dns');
        BuildUtil.writeSingleXmlElementWithChildrenAndDefaultNamespace(xsw2, 'ns', 'cols', null, 'dns');
        Test.stopTest();
        
        // Assert without a namespace
        Assert.areEqual(
            '<cols xmlns="dns"><col min="1" max="1" width="8.11"/><col min="2" max="2" width="8.11"/><col min="3" max="3" width="8.11"/></cols>',
            xsw1.getXmlString(),
            'Unexpected XML String'
        );

        // Assert with a namespace
        Assert.areEqual(
            '<ns:cols xmlns="dns"><col min="1" max="1" width="8.11"/><col min="2" max="2" width="8.11"/><col min="3" max="3" width="8.11"/></ns:cols>',
            xsw2.getXmlString(),
            'Unexpected XML String'
        );

        // Assert when it needs to be skipped
        Assert.areEqual(
            '',
            xsw3.getXmlString(),
            'Unexpected XML String'
        );
    }


    @IsTest
    static void testGetSanitizedFileName(){

        // Assert test data
        Assert.areEqual('removeExtension' + Constant.FULL_FILE_EXTENSION, BuildUtil.getSanitizedFileName('removeExtension'), 'Unexpected file name');
        Assert.areEqual('removeExtension' + Constant.FULL_FILE_EXTENSION, BuildUtil.getSanitizedFileName('removeExtension.invalid'), 'Unexpected file name');
        Assert.areEqual('removeExtension' + Constant.FULL_FILE_EXTENSION, BuildUtil.getSanitizedFileName('removeExtension' + Constant.FULL_FILE_EXTENSION), 'Unexpected file name');
    }


    @IsTest
    static void testSanitizeWorksheetName() {
        
        // Test Assertions
        Assert.areEqual( 'SHEETNAME', BuildUtil.sanitizeWorksheetName('SHEET\\/?*[]NAME'),'Unexpected sanitized name');
        Assert.areEqual( true, String.isNotEmpty(BuildUtil.sanitizeWorksheetName('\\/?*[]')), 'Unexpected sanitized name');

        // Test Exception
        try {
            BuildUtil.sanitizeWorksheetName('');
            throw new TestException(TestUtil.EXCEPTION_SAFEGUARD_MESSAGE);
        } catch (BuildException e) {
            Assert.areEqual(
                Constant.MSG_INVALID_WS_NAME, 
                e.getMessage(), 
                TestUtil.EXCEPTION_ASSERTION_MESSAGE
            );
        }

        // Test Exception
        try {
            BuildUtil.sanitizeWorksheetName('12345678901234567890123456789012');
            throw new TestException(TestUtil.EXCEPTION_SAFEGUARD_MESSAGE);
        } catch (BuildException e) {
            Assert.areEqual(
                Constant.MSG_INVALID_WS_NAME, 
                e.getMessage(), 
                TestUtil.EXCEPTION_ASSERTION_MESSAGE
            );
        }
    }
       
    
    @IsTest
    private static void testGetMaxIntegerFromList() {
        
        // Assert test values
        Assert.areEqual( 3, BuildUtil.getMaxIntegerFromList(new Integer[]{1,2,3})           ,  'Unexpected Integer');
        Assert.areEqual(60, BuildUtil.getMaxIntegerFromList(new Integer[]{10,20,60,30,40,50}), 'Unexpected Integer');
        Assert.areEqual( 0, BuildUtil.getMaxIntegerFromList(new Integer[]{}),                  'Unexpected Integer');
        Assert.areEqual( 0, BuildUtil.getMaxIntegerFromList(null),                             'Unexpected Integer');
    }
}