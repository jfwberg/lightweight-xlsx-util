/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the package and file builder classes
 * @Tests          XmlPackageBuilder
 *                 XmlFileBuilder
 *                 XmlFile
 */
@IsTest
private class XmlPackageBuilderTest {

    /**
     * @description Method to test the XmlPackageBuilder Class
     */
    @IsTest
    private static void testGetPackage(){
        
        // Variable to hold our output package
        Blob packageData;

        // Start the test
        Test.startTest();

        // Create a new builder
        Builder b = new Builder();

        // Enable shared Strings
        b.setUseSharedStrings(true);

        // Add two sheets
        b.addTextCell(0, 0, 0, '0-0-0');
        b.addTextCell(1, 1, 1, '1-1-1');

        // Create the zip blog
        packageData = XmlPackageBuilder.getPackage(b);
        
        // Strop the test
        Test.stopTest();

        // Create a Zip Reader for testing the contents of the package
        Compression.ZipReader packageReader = new Compression.ZipReader(packageData);

        // Validate that all expected files are in the zip archive
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_SHRD_STRS),     getMessage(Constant.ZP_PATH_SHRD_STRS));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_STYLES),        getMessage(Constant.ZP_PATH_STYLES));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_CORE),          getMessage(Constant.ZP_PATH_CORE));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_APP),           getMessage(Constant.ZP_PATH_APP));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_WORKBOOK),      getMessage(Constant.ZP_PATH_WORKBOOK));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_CONTENT_TYPES), getMessage(Constant.ZP_PATH_CONTENT_TYPES));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_RELS),          getMessage(Constant.ZP_PATH_RELS));
        Assert.areEqual(true, fileExistsInArchive(packageReader,Constant.ZP_PATH_WORKBOOK_RELS), getMessage(Constant.ZP_PATH_WORKBOOK_RELS));

        // Test there are two worksheets
        Assert.areEqual(true, fileExistsInArchive(packageReader,String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})), getMessage(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})));
        Assert.areEqual(true, fileExistsInArchive(packageReader,String.format(Constant.ZP_PATH_SHEET, new String[]{'1'})), getMessage(String.format(Constant.ZP_PATH_SHEET, new String[]{'1'})));
    }


    /**
     * @description Method to validate a file exist in  a zip file
     * @param packageReader The zip reader to read the package
     * @param fileName      The name to validate
     * @return file exists or not
     */
    private static Boolean fileExistsInArchive(Compression.ZipReader packageReader, String fileName){
        return packageReader?.getEntriesMap().containsKey(fileName);
    }


    /**
     * @description Method to create an assertion method
     * @param fileName The name of the missing file
     * @return      The assertion message
     */
    private static String getMessage(String fileName){
        return 'File "' + fileName + '" does not exist in the Xml Package';
    }
}