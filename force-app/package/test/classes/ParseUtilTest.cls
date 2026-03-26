/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the parser utils
 * @Tests          ParseUtil
 */
@IsTest
private class ParseUtilTest {

    @IsTest
    static void testPopulateColumnIndexMap() {

        Test.startTest();

        ParseUtil.populateColumnIndexMap(0,10);

        Test.stopTest();

        // Verify the columnIndexMap has been populated with the correct values
        Assert.areEqual(0, ParseUtil.columnIndexMap.get('A'), 'Expected column indexes to contain "A" with value "0"');
        Assert.areEqual(1, ParseUtil.columnIndexMap.get('B'), 'Expected column indexes to contain "B" with value "1"');
        Assert.areEqual(2, ParseUtil.columnIndexMap.get('C'), 'Expected column indexes to contain "C" with value "2"');
    }


    @IsTest
    static void testColumnNameFromCellName() {
        // Valid cell name
        Assert.areEqual('ALL', ParseUtil.columnNameFromCellName('ALL100'), 'Column name should match expected value.');

        // Invalid cell name
        try {
            ParseUtil.columnNameFromCellName('100invalidCellName');

            // Safeguard to make sure the test is successful
            throw new TestException(TestUtil.EXCEPTION_SAFEGUARD_MESSAGE);
            
        } catch (Exception e) {
            Assert.areEqual(
                String.format(Constant.MSG_INVALID_CELL_NAME, new String[]{'100invalidCellName'}),    
                e.getMessage(),
                TestUtil.EXCEPTION_ASSERTION_MESSAGE
            );
        }
    }
}