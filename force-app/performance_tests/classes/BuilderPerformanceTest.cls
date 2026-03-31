/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        January 2025
 * @copyright   (c) 2026 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description This class is used to test the performance of the XLSX builder
 *              Asynchronously with 12MB Heap and 60 seconds of CPU 
 *              Creates a workbook with specified number of cells, rows and worksheets
 *              where each cell has a 32 character value. This is not a bullet proof test
 *              but gives a nice indication of what is possible.
 * @note        Disable all debug levels except Apex, set Apex to DEBUG
 * @dependency  Lightweight - Debug Util (sf package install --package 04t4K000002WF5uQAG -w 30)
 * @execute     BuilderPerformanceTest.run(1,25,5000);
 *              BuilderPerformanceTest.runAsync(1,25,5000);
 * 
 */
public with sharing class BuilderPerformanceTest{

    /**
     * @description Method to test the performance of the XLSX builder Asynchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     */
    @future
    public static void runAsync(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows){
        run(numberOfWorksheets, numberOfColumns, numberOfRows);
    }


    /**
     * @description Method to test the performance of the XLSX builder Synchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     */
    public static void run(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows){
       
        // Start with a new builder object
        xlsx.Builder b = new xlsx.Builder();

        // Should be disabled for heap size testing
        b.setUseSharedStrings(true);

        // Get a timestamp string from the utils to create an easy export date
        // I Use the Constants variable here, so all timestamps referenced in the worksheet
        // are perfectly the same
        b.setFileName(xlsx.CommonUtil.getTimestampString() + '_performance_workbook.xlsx' );

        // Set the main file properties
        b.setTitle('Performance Workbook ('+xlsx.CommonUtil.getTimestampString()+ ')');
        b.setSubject('Performance');
        b.setDescription('A workbook to test the "Lightweight - XLSX Util" limits and assure maximum efficientcy');
        b.addKeyword('Workbook');
        b.addKeyword('Testing');

        // Start workbook generation time
        Decimal wbSt = Limits.getCpuTime();

        // Create a cell for each one
        for(Integer wi = 0; wi < numberOfWorksheets; wi++){

            // If you know the (rough) max number of rows and columns you can pre-pad for performance
            // improvements. 
            // Note that we work with a zero index, so we have to subtract one to prevent OOB errors
            b.prePadWorksheet(wi, numberOfColumns-1, numberOfRows-1);

            b.setAutoFilter(wi, true);

            for(Integer ri=0; ri < numberOfRows; ri++){
                for(Integer ci=0; ci < numberOfColumns; ci++){
                    b.addTextCell(wi,ci, ri, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ012345');
                }        
            }
        }

        // Workbook generation end time
        Decimal wbEt = Limits.getCpuTime();
      
        // Create a download link to the document
        String link = insertDocumentAndGetDownloadLink(
            xlsx.Build.asDocument(b)
        );

        // Build end time
        Decimal bEt = Limits.getCpuTime();

        // Create a debug log entry
        lwt.Dbg.al('TEST :: XLSX :: BUILD :: ASYNC :: ' + numberOfWorksheets + ' - ' + numberOfColumns + ' - ' + numberOfRows);        
        lwt.Dbg.al('WORKBOOK Generation Time : '        + (wbEt-wbSt));
        lwt.Dbg.al('WORKBOOK File Build Time : '        + (bEt-wbEt));
        lwt.Dbg.al('Document URL: '                     + link);
        lwt.Dbg.pub();
    }


    /**
     * @description Method to insert a Document and retrieve its download link
     * @param  d The Document to be inserted
     * @return   The download link for the inserted Document
     */
    private static String insertDocumentAndGetDownloadLink(Document d){
        insert as user d;
        return URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + d.Id;
    }
}