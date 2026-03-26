/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the styles and the styles builder
 * @tests          StylesBuilder
 *                 StylesXmlElement
 */
@IsTest
private with sharing class StylesBuilderTest {

    @IsTest
    static void testAddNumberFormat() {

        // Create a new builder
        Builder b = new Builder();
        
        // Add a number format
        StylesBuilder.addNumberFormat(b, 166, '"$"#,##0.00');

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Verify that the number format was added to the list and returned correctly
        Assert.areEqual(1, b.styleSheet.numFmts.numFmts.size(), 'Could not found the additional number format');

        // Test the XML is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><numFmts count="1"><numFmt numFmtId="166" formatCode="&quot;$&quot;#,##0.00"></numFmt></numFmts><fonts count="1"><font><sz val="11"/><color/><name val="Calibri"/><family val="2"/><scheme val="minor"/></font></fonts><fills count="2"><fill><patternFill patternType="none"></patternFill></fill><fill><patternFill patternType="125grey"></patternFill></fill></fills><borders count="1"><border><left></left><right></right><top></top><bottom></bottom><diagonal></diagonal></border></borders><cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf></cellXfs></styleSheet>',
            new Compression.ZipReader(xlsx.body).getEntry(Constant.ZP_PATH_STYLES).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testAddAlignment() {

        // Create a new builder
        Builder b = new Builder();
        
        // Create alignment
        Integer alignmentIndex = StylesBuilder.addAlignment(b, 'center', 'center', 0 , true);

        // Add the cell style
        StylesBuilder.addCellStyle(b, null, 0, 0, 0, alignmentIndex);

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Verify that the alignment was added to the list and returned correctly
        Assert.areEqual(1, b.styleSheet.alignments.alignments.size(), 'Could not found the additional alignment');

        // Test the XML is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="1"><font><sz val="11"/><color/><name val="Calibri"/><family val="2"/><scheme val="minor"/></font></fonts><fills count="2"><fill><patternFill patternType="none"></patternFill></fill><fill><patternFill patternType="125grey"></patternFill></fill></fills><borders count="1"><border><left></left><right></right><top></top><bottom></bottom><diagonal></diagonal></border></borders><cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf fontId="0" fillId="0" borderId="0" xfId="0" applyBorder="1" applyFill="1" applyFont="1"><alignment horizontal="center" vertical="center" textRotation="0" wrapText="1"/></xf></cellXfs></styleSheet>',
            new Compression.ZipReader(xlsx.body).getEntry(Constant.ZP_PATH_STYLES).getContent().toString(),
            'Unexpected XML Body'
        );
    }


    @IsTest
    static void testDefaultStyles(){

        // Create a new builder
        Builder b  = new Builder();
        Builder b2 = new Builder();

        // Include the standard styles, run a second time to validate it only runs once
        b.setIncludeDefaultStyles(true);
        b2.setIncludeDefaultStyles(true);

        // Build the document
        Document xlsx = Build.asDocument(b);

        // Header row
        Assert.areEqual(StylesBuilder.headerLeftStyleIndex,       StylesBuilder.getHeaderStyleIndex(0,0,2),  'Unexpected Style Index');  // Header left
        Assert.areEqual(StylesBuilder.headerMiddleStyleIndex,     StylesBuilder.getHeaderStyleIndex(1,0,2),  'Unexpected Style Index');  // Header middle
        Assert.areEqual(StylesBuilder.headerRightStyleIndex,      StylesBuilder.getHeaderStyleIndex(2,0,2),  'Unexpected Style Index');  // Header right
        
        // Odd row
        Assert.areEqual(StylesBuilder.mainLeftOddStyleIndex,      StylesBuilder.getMainStyleIndex(0,1,0,2,4), 'Unexpected Style Index'); // Row 1
        Assert.areEqual(StylesBuilder.mainMiddleOddStyleIndex,    StylesBuilder.getMainStyleIndex(1,1,0,2,4), 'Unexpected Style Index'); // Row 1
        Assert.areEqual(StylesBuilder.mainRightOddStyleIndex,     StylesBuilder.getMainStyleIndex(2,1,0,2,4), 'Unexpected Style Index'); // Row 1

        // even row
        Assert.areEqual(StylesBuilder.mainLeftEvenStyleIndex,     StylesBuilder.getMainStyleIndex(0,2,0,2,4), 'Unexpected Style Index'); // Row 2
        Assert.areEqual(StylesBuilder.mainMiddleEvenStyleIndex,   StylesBuilder.getMainStyleIndex(1,2,0,2,4), 'Unexpected Style Index'); // Row 2
        Assert.areEqual(StylesBuilder.mainRightEvenStyleIndex,    StylesBuilder.getMainStyleIndex(2,2,0,2,4), 'Unexpected Style Index'); // Row 2
        
        // Odd row
        Assert.areEqual(StylesBuilder.mainLeftOddStyleIndex,      StylesBuilder.getMainStyleIndex(0,3,0,2,4), 'Unexpected Style Index'); // Row 3
        Assert.areEqual(StylesBuilder.mainMiddleOddStyleIndex,    StylesBuilder.getMainStyleIndex(1,3,0,2,4), 'Unexpected Style Index'); // Row 3
        Assert.areEqual(StylesBuilder.mainRightOddStyleIndex,     StylesBuilder.getMainStyleIndex(2,3,0,2,4), 'Unexpected Style Index'); // Row 3
        
        // Bottom row even
        Assert.areEqual(StylesBuilder.bottomLeftEvenStyleIndex,   StylesBuilder.getMainStyleIndex(0,4,0,2,4), 'Unexpected Style Index'); // Row 4
        Assert.areEqual(StylesBuilder.bottomMiddleEvenStyleIndex, StylesBuilder.getMainStyleIndex(1,4,0,2,4), 'Unexpected Style Index'); // Row 4
        Assert.areEqual(StylesBuilder.bottomRightEvenStyleIndex,  StylesBuilder.getMainStyleIndex(2,4,0,2,4), 'Unexpected Style Index'); // Row 4

        // Extra test if the bottom row is odd
        Assert.areEqual(StylesBuilder.bottomLeftOddStyleIndex,    StylesBuilder.getMainStyleIndex(0,3,0,2,3), 'Unexpected Style Index'); // Row 3
        Assert.areEqual(StylesBuilder.bottomMiddleOddStyleIndex,  StylesBuilder.getMainStyleIndex(1,3,0,2,3), 'Unexpected Style Index'); // Row 3
        Assert.areEqual(StylesBuilder.bottomRightOddStyleIndex,   StylesBuilder.getMainStyleIndex(2,3,0,2,3), 'Unexpected Style Index'); // Row 3

        // Test the XML is OK
        Assert.areEqual(
            '<?xml version="1.0" encoding="UTF-8"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="3"><font><sz val="11"/><color/><name val="Calibri"/><family val="2"/><scheme val="minor"/></font><font><sz val="12"/><color rgb="242424"/><name val="Arial"/><family val="2"/><scheme val="minor"/></font><font><b/><sz val="12"/><color rgb="000000"/><name val="Arial"/><family val="2"/><scheme val="minor"/></font></fonts><fills count="5"><fill><patternFill patternType="none"></patternFill></fill><fill><patternFill patternType="125grey"></patternFill></fill><fill><patternFill patternType="gray125"><fgColor rgb="FF0b827c"/><bgColor rgb="FF06a59a"/></patternFill></fill><fill><patternFill patternType="none"><fgColor rgb="FFebf7e6"/><bgColor rgb="FF939393"/></patternFill></fill><fill><patternFill patternType="solid"><fgColor rgb="FFdef9f3"/><bgColor rgb="FFdef9f3"/></patternFill></fill></fills><borders count="10"><border><left></left><right></right><top></top><bottom></bottom><diagonal></diagonal></border><border><left style="medium"><color rgb="C9C9C9"/></left><right></right><top style="medium"><color rgb="C9C9C9"/></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="thin"><color rgb="C9C9C9"/></left><right style="thin"><color rgb="C9C9C9"/></right><top style="medium"><color rgb="C9C9C9"/></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left></left><right style="medium"><color rgb="C9C9C9"/></right><top style="medium"><color rgb="C9C9C9"/></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="medium"><color rgb="C9C9C9"/></left><right></right><top></top><bottom style="dashed"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="dotted"><color rgb="C9C9C9"/></left><right style="dotted"><color rgb="C9C9C9"/></right><top></top><bottom style="dashed"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="dashed"><color rgb="C9C9C9"/></left><right style="medium"><color rgb="C9C9C9"/></right><top></top><bottom style="dashed"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="medium"><color rgb="C9C9C9"/></left><right></right><top></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="dashed"><color rgb="C9C9C9"/></left><right style="dashed"><color rgb="C9C9C9"/></right><top></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border><border><left style="dashed"><color rgb="C9C9C9"/></left><right style="medium"><color rgb="C9C9C9"/></right><top></top><bottom style="medium"><color rgb="C9C9C9"/></bottom><diagonal></diagonal></border></borders><cellXfs count="16"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="2" fillId="2" borderId="1" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="2" fillId="2" borderId="2" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="2" fillId="2" borderId="3" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="4" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="5" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="6" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="4" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="5" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="6" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="7" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="8" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="3" borderId="9" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="7" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="8" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf><xf numFmtId="0" fontId="1" fillId="4" borderId="9" xfId="0" applyBorder="1" applyFill="1" applyFont="1" applyNumberFormat="1"></xf></cellXfs><colors><mruColors><color rgb="FF0b827c"/><color rgb="FF06a59a"/><color rgb="FFebf7e6"/><color rgb="FF939393"/><color rgb="FFdef9f3"/><color rgb="FFdef9f3"/></mruColors></colors></styleSheet>',
            new Compression.ZipReader(xlsx.body).getEntry(Constant.ZP_PATH_STYLES).getContent().toString(),
            'Unexpected XML Body'
        );
    }
}