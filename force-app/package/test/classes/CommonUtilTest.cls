/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the Common Utilities
 * @Tests          CommonUtil
 */
@IsTest
private class CommonUtilTest {

    @IsTest
    static void testColumnNameFromColumnIndex(){

        // Assert test values
        Assert.areEqual('A',   CommonUtil.columnNameFromColumnIndex(0   ), 'Expected column name "A"   to match index 0001');
        Assert.areEqual('Z',   CommonUtil.columnNameFromColumnIndex(25  ), 'Expected column name "Z"   to match index 0026');
        Assert.areEqual('AA',  CommonUtil.columnNameFromColumnIndex(26  ), 'Expected column name "AA"  to match index 0027');
        Assert.areEqual('AB',  CommonUtil.columnNameFromColumnIndex(27  ), 'Expected column name "AB"  to match index 0028');
        Assert.areEqual('AY',  CommonUtil.columnNameFromColumnIndex(50  ), 'Expected column name "AY"  to match index 0051');
        Assert.areEqual('AZ',  CommonUtil.columnNameFromColumnIndex(51  ), 'Expected column name "AZ"  to match index 0052');
        Assert.areEqual('CB',  CommonUtil.columnNameFromColumnIndex(79  ), 'Expected column name "CB"  to match index 0080');
        Assert.areEqual('YZ',  CommonUtil.columnNameFromColumnIndex(675 ), 'Expected column name "YZ"  to match index 0676');
        Assert.areEqual('ZZ',  CommonUtil.columnNameFromColumnIndex(701 ), 'Expected column name "ZZ"  to match index 0702');
        Assert.areEqual('AAC', CommonUtil.columnNameFromColumnIndex(704 ), 'Expected column name "AAC" to match index 0705');
        Assert.areEqual('ALL', CommonUtil.columnNameFromColumnIndex(999 ), 'Expected column name "ALL" to match index 1000');
    }


    @IsTest
    static void testColumnNumberFromColumnName() {

        // Assert test values
        Assert.areEqual(1,    CommonUtil.columnNumberFromColumnName('A'  ), 'Expected index 0001 to match column name "A"'  );
        Assert.areEqual(26,   CommonUtil.columnNumberFromColumnName('Z'  ), 'Expected index 0026 to match column name "Z"'  );
        Assert.areEqual(27,   CommonUtil.columnNumberFromColumnName('AA' ), 'Expected index 0027 to match column name "AA"' );
        Assert.areEqual(28,   CommonUtil.columnNumberFromColumnName('AB' ), 'Expected index 0028 to match column name "AB"' );
        Assert.areEqual(51,   CommonUtil.columnNumberFromColumnName('AY' ), 'Expected index 0051 to match column name "AY"' );
        Assert.areEqual(52,   CommonUtil.columnNumberFromColumnName('AZ' ), 'Expected index 0052 to match column name "AZ"' );
        Assert.areEqual(80,   CommonUtil.columnNumberFromColumnName('CB' ), 'Expected index 0080 to match column name "CB"' );
        Assert.areEqual(676,  CommonUtil.columnNumberFromColumnName('YZ' ), 'Expected index 0676 to match column name "YZ"' );
        Assert.areEqual(702,  CommonUtil.columnNumberFromColumnName('ZZ' ), 'Expected index 0702 to match column name "ZZ"' );
        Assert.areEqual(705,  CommonUtil.columnNumberFromColumnName('AAC'), 'Expected index 0705 to match column name "AAC"');
        Assert.areEqual(1000, CommonUtil.columnNumberFromColumnName('ALL'), 'Expected index 1000 to match column name "ALL"');
    }


    @IsTest
    static void testCellName() {

        // Assert test values
        Assert.areEqual('A1',      CommonUtil.cellName(  0,  0), 'Expected cell name to be "A1"'     );
        Assert.areEqual('Z26',     CommonUtil.cellName( 25, 25), 'Expected cell name to be "Z26"'    );
        Assert.areEqual('AA27',    CommonUtil.cellName( 26, 26), 'Expected cell name to be "AA27"'   );
        Assert.areEqual('AB28',    CommonUtil.cellName( 27, 27), 'Expected cell name to be "AB28"'   );
        Assert.areEqual('AY51',    CommonUtil.cellName( 50, 50), 'Expected cell name to be "AY51"'   );
        Assert.areEqual('AZ52',    CommonUtil.cellName( 51, 51), 'Expected cell name to be "AZ52"'   );
        Assert.areEqual('CB80',    CommonUtil.cellName( 79, 79), 'Expected cell name to be "CB80"'   );
        Assert.areEqual('YZ676',   CommonUtil.cellName(675,675), 'Expected cell name to be "YZ676"'  );
        Assert.areEqual('ZZ702',   CommonUtil.cellName(701,701), 'Expected cell name to be "ZZ702"'  );
        Assert.areEqual('AAC705',  CommonUtil.cellName(704,704), 'Expected cell name to be "AAC705"' );
        Assert.areEqual('ALL1000', CommonUtil.cellName(999,999), 'Expected cell name to be "ALL1000"');
    }


    @IsTest
    static void testRandomHtmlHexColorCode() {

        // Assertion variables
        String colorCode;

        // Execute tests
        Test.startTest();
        colorCode = CommonUtil.randomHtmlHexColorCode();
        Test.stopTest();

        // Assert test values
        Assert.areEqual(6,    colorCode.length(),                       'Color code should have 6 characters');
        Assert.areEqual(true, Pattern.matches('^[0-9a-f]*', colorCode), 'Color code should only have hexadecimal characters');
    }


    @IsTest
    private static void testGetTimestamp() {

        // Assert test values
        Assert.areEqual(Constant.NOW, CommonUtil.getTimeStamp(), 'Unexpected timestamp');
    }


    @IsTest
    private static void testGetTimestampString() {

        // Assert test values
        Assert.areEqual(Constant.NOW.format(Constant.TIMESTAMP_FORMAT), CommonUtil.getTimestampString(), 'Unexpected timestamp format');
    }

    
    /**
     * @description Method to test the static resource utility
     */
    @IsTest
    static void testGetStaticResourceBody(){
        try{
            CommonUtil.getStaticResourceBody('invalid');
        }catch(CommonUtil.InvalidDataException e){
            Assert.areEqual(
                String.format(Constant.MSG_STATIC_RESOURCE_ERROR, new String[]{'invalid'}),
                e.getMessage(),
                'Unexpected Exception Message'
            );
        }
	}

}