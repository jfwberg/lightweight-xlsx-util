/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the Builder
 * @tests          Builder
 *                 XmlElement
 */
@IsTest
private with sharing class BuilderTest {

    @IsTest
    static void testDocumentProperties(){

        // Create a new builder file
        Builder b = new Builder();

        // Few settings for coverage
        b.setUseSharedStrings(false);
        b.setIncludeDefaultStyles(true);

        // Set document properties
        b.setFileName('test_file_name');
        b.setTitle('Test Title');
        b.setSubject('Test Subject');
        b.setDescription('Test Description');
        b.addKeyword('Test Keyword');

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Test the core.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><coreProperties xmlns="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><dcterms:created xsi:type="dcterms:W3CDTF">'+Constant.NOW.format(Constant.ISO_8601_FORMAT)+'</dcterms:created><dc:title>Test Title</dc:title><dc:subject>Test Subject</dc:subject><dc:creator>'+Constant.CREATOR+'</dc:creator><keywords>Test Keyword</keywords><dc:description>Test Description</dc:description><revision>'+Constant.REVISION+'</revision></coreProperties>',
            new Compression.ZipReader(xlsx.body).getEntry(Constant.ZP_PATH_CORE).getContent().toString(),
            'Unexpected XML Body'
        );

        // Test the app.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"><Company>'+Constant.COMPANY_NAME+'</Company><Application>'+Constant.APP_NAME+'</Application></Properties>',
            new Compression.ZipReader(xlsx.body).getEntry(Constant.ZP_PATH_APP).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testPrivateGetters(){

        // Create a new builder file
        Builder b = new Builder();

        // Create a new worksheets
        Integer wi = b.addWorksheet('Sheet01');

        // Get the 5th column, that does not exist but should return a new column
        Assert.areEqual(
            false,
            b.getColumn(wi,4) == null,
            'Unexpected Column'
        );

        // Get the 5th row, that does not exist but should return a new row
        Assert.areEqual(
            false,
            b.getRow(wi,5) == null,
            'Unexpected Row'
        );

        // Get the 5th row, that does not exist but should return a new row
        Assert.areEqual(
            false,
            b.getCell(5,5,5) == null,
            'Unexpected Cell'
        );
    }


    @IsTest
    static void testWorksheet(){

        // Create a new builder file
        Builder b = new Builder();

        // Few settings for coverage, keep at false!!
        b.setUseSharedStrings(false);

        // Create a new worksheets
        Integer wi  = b.addWorksheet('Sheet01');

        // Add a dash of color to our boring test
        b.setTabColor(wi,'FFCCFF');

        // Apply some pre padding, the test should remove the lasts columns
        b.prePadWorksheet(wi, 15, 15);

        // Hide the sheet
        b.setVisible(wi,false);

        // Apply the auto filter
        b.setAutoFilter(wi, true);

        // Add two cells with some info
        b.addTextCell(wi, 0, 0, 'A1');
        b.addTextCell(wi, 9, 9, 'J10');

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Test the sheet0.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor rgb="FFCCFF"/></sheetPr><dimension ref="A1:J10"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><sheetData><row r="1"><c r="A1" t="inlineStr"><is><t>A1</t></is></c></row><row r="10"><c r="J10" t="inlineStr"><is><t>J10</t></is></c></row></sheetData><autoFilter ref="A1:J1"/><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testWorksheetExceptions(){
        try{
            // Create a new builder file
            Builder b = new Builder();

            // Add the first sheet
            b.addWorksheet('Sheet01');

            // Add cells to cover multiple shared strings coverage
            b.addTextCell(0,0,0,'A1');
            b.addTextCell(1,0,0,'A1');

            // Add a second blank worksheet
            b.addWorksheet(null);

            // Add a duplicate name for the exception
            b.addWorksheet('Sheet01');

            // This part of the code should not be reached
            throw new TestException(TestUtil.EXCEPTION_SAFEGUARD_MESSAGE);

        }catch(BuildException e){
            Assert.areEqual(
                String.format(Constant.MSG_DUPLICATE_WORKSHEET, new String[]{'Sheet01'}),
                e.getMessage(),
                TestUtil.EXCEPTION_ASSERTION_MESSAGE
            );
        }
    }


    @IsTest
    static void testFreezeRowsAndColumns(){

        // Create a new builder file
        Builder b = new Builder();

        // Both
        Integer wi0 = b.addWorksheet('Both');
        b.prePadWorksheet(wi0, 2, 2);
        b.setFreezeRows(0, 2);
        b.setFreezeColumns(wi0, 2);

        // Rows only
        Integer wi1 = b.addWorksheet('Rows');
        b.prePadWorksheet(wi1, 2, 2);
        b.setFreezeRows(wi1, 2);

        // Columns
        Integer wi2 = b.addWorksheet('Cols');
        b.prePadWorksheet(wi2, 2, 2);
        b.setFreezeColumns(wi2, 2);

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Test the sheet0.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><pane ySplit="2" xSplit="2" topLeftCell="C3" activePane="bottomRight" state="frozen"/><selection pane="topRight" activeCell="C1" sqref="C1"/><selection pane="bottomLeft" activeCell="A3" sqref="A3"/><selection pane="bottomRight" activeCell="C3" sqref="C3"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );

        // Test the sheet1.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><pane ySplit="2" topLeftCell="A3" activePane="bottomLeft" state="frozen"/><selection pane="bottomLeft" activeCell="A3" sqref="A3"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'1'})).getContent().toString(),
            'Unexpected XML Body'
        );

        // Test the sheet2.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><pane xSplit="2" topLeftCell="C1" activePane="topRight" state="frozen"/><selection pane="topRight" activeCell="C1" sqref="C1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'2'})).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testAddCells(){

        // Create a new builder file
        Builder b = new Builder();

        // Add cell methods
        b.addNumberCell(0,0,0,12);
        b.addNumberCell(0,1,1,123.45);
        b.addBooleanCell(0,2,2,true);
        b.addFormulaCell(0, 3, 3, '125.45', '=SUM(A1,B2)');
        b.addTextCell(0,4,4,'text value');

        // Add cell methods with style index
        b.addNumberCell(1,0,0,12,0);
        b.addNumberCell(1,1,1,123.45,0);
        b.addBooleanCell(1,2,2,true,0);
        b.addFormulaCell(1, 3, 3, '125.45', '=SUM(A1,B2)',0);
        b.addTextCell(1,4,4,'text value',0);

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Test the sheet0.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:E5"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><sheetData><row r="1"><c r="A1" t="n"><v>12</v></c></row><row r="2"><c r="B2" t="n"><v>123.45</v></c></row><row r="3"><c r="C3" t="b"><v>true</v></c></row><row r="4"><c r="D4" t="str"><f>=SUM(A1,B2)</f><v>125.45</v></c></row><row r="5"><c r="E5" t="s"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );

        // Test the sheet1.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:E5"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><sheetData><row r="1"><c r="A1" t="n" s="0"><v>12</v></c></row><row r="2"><c r="B2" t="n" s="0"><v>123.45</v></c></row><row r="3"><c r="C3" t="b" s="0"><v>true</v></c></row><row r="4"><c r="D4" t="str" s="0"><f>=SUM(A1,B2)</f><v>125.45</v></c></row><row r="5"><c r="E5" t="s" s="0"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'1'})).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testMergeCellsAndHyperlinks(){

        // Create a new builder file
        Builder b = new Builder();

        // We need the name for the hyperlinks
        String worksheetName = 'WS1';

        // Create a new worksheet
        Integer wi = b.addWorksheet(worksheetName);

        // Add two cells
        b.addTextCell(wi, 0, 0, 'merge', 0);
        b.addTextCell(wi, 1, 1, null);

        // Merge the cells
        b.addMergeCell(wi, 0, 0, 1, 1);

        // Get the target cell A1 ([0][0])
        String ws1A1TargetCell = CommonUtil.cellName(0,0);

        // The Completed target worksheet + the cell in that worksheet format looks like this: "'Worksheet 01'!A1"
        String ws1A1Hyperlink = '\''+ worksheetName +'\'!' + ws1A1TargetCell;

        // Add hyperlinks (Worksheet index, Column Index, RowIndex, location/target, display value)
        // Note the the display value does not do anything due to how single string are implemented, but this is future proofing
        b.addTextCell(1, 1, 1, 'Link to A1');
        b.addHyperlink(1, 1,1, ws1A1Hyperlink, '');

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Test the sheet0.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:B2"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><sheetData><row r="1"><c r="A1" t="s" s="0"><v>0</v></c></row><row r="2"><c r="B2" t="s"><v>1</v></c></row></sheetData><mergeCells><mergeCell ref="A1:B2"/></mergeCells><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );

        // Test the sheet1.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:B2"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><sheetData><row r="2"><c r="B2" t="s"><v>2</v></c></row></sheetData><hyperlinks><hyperlink ref="B2" location="\'WS1\'!A1" display=""></hyperlink></hyperlinks><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsx.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'1'})).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testSettersAndBuildAs(){

        // Create a new builder file
        Builder b = new Builder();

        // Create a new worksheet
        b.addWorksheet('Setters');
        b.addKeyword('Build Test');

        // Add text cell
        b.addTextCell(0, 0, 0, 'A1');

        // Columns
        b.setCellStyle(0, 0, 0,0);

        // Column setters
        b.setColHidden(0, 0, false);
        b.setColWidth( 0, 0, 45);
        b.setColStyle( 0, 0, 0);

        // Row setters
        b.setRowHidden( 0, 0, false);
        b.setRowHeight( 0, 0, 45);
        b.setRowStyle(  0, 0, 0);

        // Build the document
        Blob                          xlsxBlob                = Build.asBlob(b);
        Document                      xlsxDocument            = Build.asDocument(b);
        ContentVersion                xlsxContentVersion      = Build.asContentVersion(b);
        Messaging.EmailFileAttachment xlsxEmailFileAttachment = Build.asEmailFileAttachment(b);

        // Test the sheet0.xml is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><cols><col min="1" max="1" width="45.00" customWidth="1" style="0" hidden="true"/></cols><sheetData><row r="1" s="0" customFormat="1" ht="45.00" customHeight="1" hidden="true"><c r="A1" t="s" s="0"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsxBlob).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );
        
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><cols><col min="1" max="1" width="45.00" customWidth="1" style="0" hidden="true"/></cols><sheetData><row r="1" s="0" customFormat="1" ht="45.00" customHeight="1" hidden="true"><c r="A1" t="s" s="0"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsxContentVersion.VersionData).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );
        
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><cols><col min="1" max="1" width="45.00" customWidth="1" style="0" hidden="true"/></cols><sheetData><row r="1" s="0" customFormat="1" ht="45.00" customHeight="1" hidden="true"><c r="A1" t="s" s="0"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsxDocument.body).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );
        
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheetPr><tabColor auto="true"/></sheetPr><dimension ref="A1:A1"/><sheetViews><sheetView workbookViewId="0"><selection activeCell="A1" sqref="A1"/></sheetView></sheetViews><sheetFormatPr defaultColWidth="8.11" defaultRowHeight="14.40"/><cols><col min="1" max="1" width="45.00" customWidth="1" style="0" hidden="true"/></cols><sheetData><row r="1" s="0" customFormat="1" ht="45.00" customHeight="1" hidden="true"><c r="A1" t="s" s="0"><v>0</v></c></row></sheetData><pageMargins left="0.75" right="0.75" top="0.75" bottom="0.75" header="0.25" footer="0.25"/></worksheet>',
            new Compression.ZipReader(xlsxEmailFileAttachment.getBody()).getEntry(String.format(Constant.ZP_PATH_SHEET, new String[]{'0'})).getContent().toString(),
            'Unexpected XML Body'
        );
    }
}