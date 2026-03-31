/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        January 2025
 * @copyright   (c) 2026 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description Basic performance test to read an XLXS file using the XLSXParser class.
 *              iterate all results and execute a sample action on each cell to have some
 *              sort of realistic feel of handling results
 * @note        Disable all debug levels except Apex, set Apex to DEBUG
 * @dependency  Lightweight - Debug Util (sf package install --package 04t4K000002WF5uQAG -w 30)
 * @execute     xlsx.ParserPerformanceTest.parseToArray(1,25,5000,'015Qz000004lyckIAA');
 *              xlsx.ParserPerformanceTest.parseToArrayAsync(1,25,5000,'015Qz000004lyckIAA');
 *              xlsx.ParserPerformanceTest.parseToMap(1,25,5000,'015Qz000004lyckIAA');
 *              xlsx.ParserPerformanceTest.parseToMapAsync(1,25,5000,'015Qz000004lyckIAA');
 */
public with sharing class ParserPerformanceTest {

    /**
     * @description Method to test the performance of the XLSX parser to Array Asynchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */
    @future
    public static void parseToArrayAsync(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){
        parseToArray(numberOfWorksheets, numberOfColumns, numberOfRows, documentId);
    }


    /**
     * @description Method to test the performance of the XLSX parser to Array Synchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */
    public static void parseToArray(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){

        // Register start time
        Decimal st = Limits.getCpuTime();

        // Parse the file
        Object[][][] xlsxDataArray = xlsx.Parse.toArray(
            new Compression.ZipReader(
                [SELECT body FROM Document WHERE Id = :documentId LIMIT 1].Body
            ).getEntriesMap()
        );

        

        // Register end time
        Decimal pt = Limits.getCpuTime();

        // Example action
        Object cellData;

        // Counters
        Integer wiCount   = 0;
        Integer rowCount  = 0;
        Integer colCount  = 0;
        Integer cellCount = 0;

        // Loop through the results and do something
        for(Integer wi=0, wiMax=xlsxDataArray.size(); wi<wiMax; wi++){
            
            if(wi == 0){wiCount+=wiMax;}
            
            for(Integer ci=0, ciMax=xlsxDataArray[wi].size(); ci<ciMax; ci++){
                
                // Add accurate count
                if(ci == 0){
                    colCount+=ciMax;
                    rowCount+=xlsxDataArray[wi][ci].size();
                }
                
                for(Integer ri=0, riMax=xlsxDataArray[wi][ci].size(); ri<riMax; ri++){
                    cellData = xlsxDataArray[wi][ci][ri];
                    cellCount++;
                }      
            }
        }

        // Register final end time
        Decimal et = Limits.getCpuTime();

        // Create a debug log
        lwt.Dbg.al('numberOfWorksheets' + ': ' + numberOfWorksheets );
        lwt.Dbg.al('numberOfColumns'    + ': ' + numberOfColumns    );
        lwt.Dbg.al('numberOfRows'       + ': ' + numberOfRows       );
        lwt.Dbg.al('documentId'         + ': ' + documentId         );
        lwt.Dbg.al('wiCount'            + ': ' + wiCount            );
        lwt.Dbg.al('rowCount'           + ': ' + rowCount           );
        lwt.Dbg.al('colCount'           + ': ' + colCount           );
        lwt.Dbg.al('cellCount'          + ': ' + cellCount          );
        lwt.Dbg.al('PARSE Time'         + ': ' + (pt-st)            );
        lwt.Dbg.al('HANDLING Time'      + ': ' + (et-pt)            );
        lwt.Dbg.pub();
    }


    /**
     * @description Method to test the performance of the XLSX parser to Map Asynchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */
    @future
    public static void parseToMapAsync(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){
        parseToMap(numberOfWorksheets, numberOfColumns, numberOfRows, documentId);
    }


    /**
     * @description Method to test the performance of the XLSX parser to Map Synchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */    
    public static void parseToMap(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){

        // Register start time
        Decimal st = Limits.getCpuTime();

        // Parse the file
        List<Map<String,Object>> xlsxDataMapList = xlsx.Parse.toMap(
            new Compression.ZipReader(
                [SELECT body FROM Document WHERE Id = :documentId LIMIT 1].Body
            ).getEntriesMap()
        );

        // Register end time
        Decimal pt = Limits.getCpuTime();

        // Example action
        Object cellData;

        // Loop through the results and do something
        for(Integer wi=0, wiMax=xlsxDataMapList.size(); wi<wiMax; wi++){
            for(String cKey : xlsxDataMapList[wi].keySet()){
                cellData = xlsxDataMapList[wi].get(cKey);
            }
        }

        // Register final end time
        Decimal et = Limits.getCpuTime();

        // Create a debug log
        lwt.Dbg.al('numberOfWorksheets' + ': ' + numberOfWorksheets );
        lwt.Dbg.al('numberOfColumns'    + ': ' + numberOfColumns    );
        lwt.Dbg.al('numberOfRows'       + ': ' + numberOfRows       );
        lwt.Dbg.al('documentId'         + ': ' + documentId         );
        lwt.Dbg.al('PARSE Time'         + ': ' + (pt-st)            );
        lwt.Dbg.al('HANDLING Time'      + ': ' + (et-pt)            );
        lwt.Dbg.pub();
    }


    /**
     * @description Method to test the performance of the XLSX parser to Map Asynchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */
    @future
    public static void parseToLlmTextAsync(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){
        parseToLlmText(numberOfWorksheets, numberOfColumns, numberOfRows, documentId);
    }


    /**
     * @description Method to test the performance of the XLSX parser to Map Synchronously
     * @param numberOfWorksheets The number of worksheets to create
     * @param numberOfColumns    The number of columns to create
     * @param numberOfRows       The number of rows to create
     * @param documentId         The Id of the file to read
     */    
    public static void parseToLlmText(Integer numberOfWorksheets, Integer numberOfColumns, Integer numberOfRows, String documentId){

        // Register start time
        Decimal st = Limits.getCpuTime();

        // Parse the file
        String output = xlsx.Parse.toLlmText(
            new Compression.ZipReader(
                [SELECT body FROM Document WHERE Id = :documentId LIMIT 1].Body
            ).getEntriesMap()
        );

        // Register end time
        Decimal pt = Limits.getCpuTime();

        // Create a debug log
        lwt.Dbg.al('numberOfWorksheets' + ': ' + numberOfWorksheets );
        lwt.Dbg.al('numberOfColumns'    + ': ' + numberOfColumns    );
        lwt.Dbg.al('numberOfRows'       + ': ' + numberOfRows       );
        lwt.Dbg.al('documentId'         + ': ' + documentId         );
        lwt.Dbg.al('PARSE Time'         + ': ' + (pt-st)            );
        lwt.Dbg.pub();
    }
}