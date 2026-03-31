/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds methods to create a Styles.xml file
 *
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 * @false-positive ExcessiveParameterList   I need to find a nicer way for the massive amount of parameters.
 *                                          Unfortunately there are many of them and this is the easiest for now.
 * @false-positive CognitiveComplexity      Way over the threshold, but this is because of the nature
 *                                          of lots of small XML writing statements with null cells.
 *                                          Unless you split into many different files, the complexity
 *                                          will be very high, but it's not difficult to read.
 * @false-positive CyclomaticComplexity     Caused by the many if statements and null checks for many
 *                                          individual XML element checks and validations
 * @false-positive StdCyclomaticComplexity  Just 1 over the threshold, I can live with that
 * @false-positive TooManyFields            The styles have a lot of parameters we have to deal with, but it's
 *                                          the easiest to have it all together
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.TooManyFields, PMD.ExcessiveParameterList')
global with sharing class StylesBuilder {

    // Make sure the default and required styles are only applied once
    private static Boolean requiredStylesApplied      = false;
    private static Boolean defaultStylesApplied       = false;

    // Header row styles
    @TestVisible private static Integer headerLeftStyleIndex       = 0;
    @TestVisible private static Integer headerRightStyleIndex      = 0;
    @TestVisible private static Integer headerMiddleStyleIndex     = 0;

    // Main row odd styles
    @TestVisible private static Integer mainLeftOddStyleIndex      = 0;
    @TestVisible private static Integer mainRightOddStyleIndex     = 0;
    @TestVisible private static Integer mainMiddleOddStyleIndex    = 0;

    // Main row even styles
    @TestVisible private static Integer mainLeftEvenStyleIndex     = 0;
    @TestVisible private static Integer mainRightEvenStyleIndex    = 0;
    @TestVisible private static Integer mainMiddleEvenStyleIndex   = 0;

    // Bottom row odd styles
    @TestVisible private static Integer bottomLeftOddStyleIndex    = 0;
    @TestVisible private static Integer bottomRightOddStyleIndex   = 0;
    @TestVisible private static Integer bottomMiddleOddStyleIndex  = 0;

    // Bottom row odd styles
    @TestVisible private static Integer bottomLeftEvenStyleIndex   = 0;
    @TestVisible private static Integer bottomRightEvenStyleIndex  = 0;
    @TestVisible private static Integer bottomMiddleEvenStyleIndex = 0;


    /**
     * @description Method to add custom number formats
     * @param b          xlsx.Builder class instance
     * @param numFmtId   Number format id
     * @param formatCode The format code
     * @return The actual format and NOT the index in this case
     */
    global static Integer addNumberFormat(Builder b, Integer numFmtId, String formatCode){

        // Add number format
        b.styleSheet.numFmts.numFmts.add(new XmlElementStyles.NumFmt(numFmtId, formatCode));

        // return the actual format and NOT the index in this case
        return numFmtId;
    }


    /**
     * @description Method to add a font to the builder
     * @param b          xlsx.Builder class instance
     * @param sz         Font size
     * @param name       Font name
     * @param rgb        Font color in RGB format
     * @param bold       True if font is bold, false otherwise
     * @param italic     True if font is italic, false otherwise
     * @param underline  True if font is underlined, false otherwise
     * @return The font index
     */
    global static Integer addFont(Builder b, Integer sz, String name, String rgb, Boolean bold, Boolean italic, Boolean underline){

        // Create a new font
        XmlElementStyles.Font font = new XmlElementStyles.Font();

        font.b = bold;
        font.i = italic;
        font.u = underline;

        font.sz     = new XmlElementStyles.FontAttribute('sz',     sz     );
        font.name   = new XmlElementStyles.FontAttribute('name',   name   );
        font.family = new XmlElementStyles.FontAttribute('family', 2      );
        font.scheme = new XmlElementStyles.FontAttribute('scheme', 'minor');

        // Create a font color
        XmlElementStyles.Color color = new XmlElementStyles.Color(rgb);
        font.color = color;

        b.styleSheet.fonts.fonts.add(font);

        // return the font index
        return b.styleSheet.fonts.fonts.size() -1;
    }


    /**
     * @description Method to add a fill to the builder
     * @param b           xlsx.Builder class instance
     * @param patternType Pattern type (e.g. 'olid', 'gray125', 'gray75', 'gray50', 'gray25', 'none')
     * @param fgColor     Foreground color in RGB format
     * @param bgColor     Background color in RGB format
     * @return The fill index
     */
    global static Integer addFill(Builder b, String patternType, String fgColor, String bgColor){

        // Create the fill
        XmlElementStyles.Fill fill = new XmlElementStyles.Fill();
        fill.patternFill = new XmlElementStyles.patternFill(
            patternType,
            fgColor != null ? 'FF' + fgColor : null,
            bgColor != null ? 'FF' + bgColor : null
        );
        b.styleSheet.fills.fills.add(fill);

        // Add the ARGB code for the fg color
        if(String.isNotBlank(fgColor)){
            b.styleSheet.colors.mruColors.colors.add(new XmlElementStyles.Color('FF' + fgColor));
        }

        // Add the ARGB code for the Bg color
        if(String.isNotBlank(bgColor)){
            b.styleSheet.colors.mruColors.colors.add(new XmlElementStyles.Color('FF' + bgColor));
        }

        // REturn the fill index
        return b.styleSheet.fills.fills.size()-1;
    }


    /**
     * @description Method to configure border settings for a worksheet
     * @param style Border style (e.g. 'thin', 'edium', 'thick', 'dashed', 'dotted',
     *              'double', 'hair', 'ediumDashed', 'dashDot', 'ediumDashDot', 
     *              'dashDotDot', 'ediumDashDotDot', 'none')
     * @param color Border color in hex format
     * @return      A map of border settings
     */
    global static Map<String,String> borderConfig(String style, String color){
        return new Map<String,String>{
            'style' => style,
            'color' => color
        };
    }


    /**
     * @description Adds a border to the table.
     * @param b      The builder object to add the border to.
     * @param left   The attributes for the left border.
     * @param right  The attributes for the right border.
     * @param top    The attributes for the top border.
     * @param bottom The attributes for the bottom border.
     * @return       The border index.
     */
    global static Integer addBorder(Builder b, Map<String,String> left, Map<String,String> right, Map<String,String> top, Map<String,String> bottom){

        XmlElementStyles.Border border = new XmlElementStyles.Border();

        if(left != null){
            border.left.style = left.get('style');
            border.left.color = new XmlElementStyles.Color(left.get('color'));
        }

        if(right != null){
            border.right.style = right.get('style');
            border.right.color = new XmlElementStyles.Color(right.get('color'));
        }

        if(top != null){
            border.top.style = top.get('style');
            border.top.color = new XmlElementStyles.Color(top.get('color'));
        }

        if(bottom != null){
            border.bottom.style = bottom.get('style');
            border.bottom.color = new XmlElementStyles.Color(bottom.get('color'));
        }
        b.styleSheet.borders.borders.add(border);

        // Return the border index
        return b.styleSheet.borders.borders.size()-1;
    }


    /**
     * @description Adds alignment to the table.
     * @param b              The builder object to add the alignment to.
     * @param horizontal     The horizontal alignment.
     * @param vertical       The vertical alignment.
     * @param textRotation   The text rotation.
     * @param wrapText       Indicates whether to wrap text.
     * @return      The alignment index.
     */
    global static Integer addAlignment(Builder b, String horizontal, String vertical, Integer textRotation, Boolean wrapText) {

        // Create element
        XmlElementStyles.Alignment alignment = new XmlElementStyles.Alignment(
            horizontal,
            vertical,
            textRotation,
            wrapText
        );
        b.styleSheet.alignments.alignments.add(alignment);

        // Return the alignment index
        return b.styleSheet.alignments.alignments.size()-1;
    }


    /**
     * @description Adds a cell style to the workbook.
     * @param b           The builder object to add the cell style to.
     * @param numFmtId    The number format ID for the cell style.
     * @param fontId      The font ID for the cell style.
     * @param fillId      The fill ID for the cell style.
     * @param borderId    The border ID for the cell style.
     * @param alignmentId The alignment ID for the cell style.
     * @return      The index of the added cell style.
     */
    global static Integer addCellStyle(Builder b, Integer numFmtId, Integer fontId, Integer fillId, Integer borderId, Integer alignmentId){

        // Create style
        XmlElementStyles.Xf xf = new XmlElementStyles.Xf();
        xf.numFmtId    = numFmtId;
        xf.fontId      = fontId;
        xf.fillId      = fillId;
        xf.borderId    = borderId;
        xf.xfId        = 0;

        xf.applyNumberFormat = numFmtId != null;
        xf.applyFont         = fontId   != null;
        xf.applyFill         = fillId   != null;
        xf.applyBorder       = borderId != null;

        // Add a full alignment object from the list.
        if(alignmentId != null && alignmentId >= 0){

            // Validate the id is within bounds
            if(b.styleSheet.alignments.alignments.size()-1 >= alignmentId ){
                xf.alignment = b.styleSheet.alignments.alignments[alignmentId];
            }
        }

        // Add the cell style
        b.styleSheet.cellXfs.cellXfs.add(xf);

        // Return the cellStyle Index
        return b.styleSheet.cellXfs.cellXfs.size()-1;
    }


    /**
     * @description Method to retrieve header style index based on the current column index and start/end column indices.
     * @param ci      The current column index.
     * @param startCi The start column index.
     * @param endCi   The end column index.
     * @return      The header style index.
     */
    global static Integer getHeaderStyleIndex(Integer ci, Integer startCi, Integer endCi){
        return (ci == startCi) ? headerLeftStyleIndex : (ci == endCi) ? headerRightStyleIndex : headerMiddleStyleIndex;
    }


    /**
     * @description Method to retrieve the main style index based on the current column index, row index, and start/end column indices.
     * @param ci      The current column index.
     * @param ri      The current row index.
     * @param startCi The start column index.
     * @param endCi   The end column index.
     * @param endRi   The maximum row index.
     * @return      The main style index.
     */
    global static Integer getMainStyleIndex(Integer ci, Integer ri, Integer startCi, Integer endCi, Integer endRi){

        // Create a different background for even / uneven rows
        Boolean even = Math.mod(ri, 2) == 0;

        // Return either the main style for all rows or a thick border bottom for the bottom row
        return
            (ci == startCi) ? ((ri< endRi) ? ((even) ? mainLeftEvenStyleIndex   : mainLeftOddStyleIndex  ) : ((even) ? bottomLeftEvenStyleIndex   : bottomLeftOddStyleIndex))  :   // left
            (ci == endCi)   ? ((ri< endRi) ? ((even) ? mainRightEvenStyleIndex  : mainRightOddStyleIndex ) : ((even) ? bottomRightEvenStyleIndex  : bottomRightOddStyleIndex)) :   // Right
            ((ri < endRi)   ?                ((even) ? mainMiddleEvenStyleIndex : mainMiddleOddStyleIndex) : ((even) ? bottomMiddleEvenStyleIndex : bottomMiddleOddStyleIndex))    // Middle
        ;
    }


    /**
     * @description Method to setup the mandatory Styles in the Styles.xml document
     *              this set of styles is required for the XLSX to work with Excel
     * @param b     The builder to populate the default styles to.
     */
    public static void populateDefaultRequiredStyles(Builder b){

        // Do nothing if the required styles are already applied
        if(requiredStylesApplied){
            return;
        }

        // Add font
        addFont( b, 11, 'Calibri', null, false, false, false);

        // Add default fills, both are required or the index breaks in excel
        addFill(b, 'none',    null, null);
        addFill(b, '125grey', null, null);

        // Border
        addBorder(b, null,null,null,null);

        // Default XFs
        addCellStyle(b, 0, 0, 0, 0, null);

        // Set the required styles to true so it does not run again
        requiredStylesApplied = true;
    }


    /**
     * @description Method to setup the optional Styles in the Styles.xml document
     *              this can be customized so you always have your company's styles
     *              A set of 15 table styles is created to format styles like below:
     *              +======================================+==========================+===========+
     *              | header left            | header middle            | header right            |
     *              +======================================+==========================+===========+
     *              | main left (odd/even)   | main middle (odd/even)   | main right (odd/even)   |
     *              +--------------------------------------+--------------------------+-----------+
     *              | bottom left (odd/even) | bottom middle (odd/even) | bottom right (odd/even) |
     *              +--------------------------------------+--------------------------+-----------+
     *
     * @note        Use the getHeaderStyleIndex() and getMainStyleIndex() methods to get the corresponding indexes
     *              fully automatically
     * @param b     The builder to populate the default styles to.
     */
    public static void populateDefaultStyles(Builder b){

        // Do nothing if the default styles are already applied
        if(defaultStylesApplied){
            return;
        }

        // Default border color
        String borderColor = 'C9C9C9';

        // Create fonts (Builder, Size, Name, Color, Bold, Italic, Underline)
        Integer mainFontIndex     = addFont(b, 12, 'Arial', '242424', false, false, false);
        Integer headerFontIndex   = addFont(b, 12, 'Arial', '000000', true,  false, false);

        // Create fills (Builder, patternType, foreground color, background color)
        Integer headerFillIndex   = addFill(b, 'gray125', '0b827c', '06a59a');
        Integer mainFillOddIndex  = addFill(b, 'none',    'ebf7e6', '939393');
        Integer mainFillEvenIndex = addFill(b, 'solid',   'def9f3', 'def9f3');

        // Header left border
        Integer headerLeftBorder   = addBorder(b,
            borderConfig('medium', borderColor),
            null,
            borderConfig('medium', borderColor),
            borderConfig('medium', borderColor)
        );

        // Header middle border
        Integer headerMiddleBorder = addBorder(b,
            borderConfig('thin',   borderColor),
            borderConfig('thin',   borderColor),
            borderConfig('medium', borderColor),
            borderConfig('medium', borderColor)
        );

        // Header right border
        Integer headerRightBorder  = addBorder(b,
            null,
            borderConfig('medium', borderColor),
            borderConfig('medium', borderColor),
            borderConfig('medium', borderColor)
        );

        // Main left border
        Integer mainLeftBorder     = addBorder(b,
            borderConfig('medium', borderColor),
            null,
            null,
            borderConfig('dashed', borderColor)
        );

        // Main middle border
        Integer mainMiddleBorder   = addBorder(b,
            borderConfig('dotted', borderColor),
            borderConfig('dotted', borderColor),
            null,
            borderConfig('dashed', borderColor)
        );

        // Main right border
        Integer mainRightBorder   = addBorder(b,
            borderConfig('dashed', borderColor),
            borderConfig('medium', borderColor),
            null,
            borderConfig('dashed', borderColor)
        );

        // Bottom left border
        Integer bottomLeftBorder  = addBorder(b,
            borderConfig('medium', borderColor),
            null,
            null,
            borderConfig('medium', borderColor)
        );

        // Bottom middle border
        Integer bottomMiddleBorder = addBorder(b,
            borderConfig('dashed', borderColor),
            borderConfig('dashed', borderColor),
            null,
            borderConfig('medium', borderColor)
        );

        // Bottom right border
        Integer bottomRightBorder  = addBorder(b,
            borderConfig('dashed', borderColor),
            borderConfig('medium', borderColor),
            null,
            borderConfig('medium', borderColor)
        );

        // Header
        headerLeftStyleIndex       = addCellStyle(b, 0, headerFontIndex, headerFillIndex,   headerLeftBorder  , null);
        headerMiddleStyleIndex     = addCellStyle(b, 0, headerFontIndex, headerFillIndex,   headerMiddleBorder, null);
        headerRightStyleIndex      = addCellStyle(b, 0, headerFontIndex, headerFillIndex,   headerRightBorder , null);

        // Main Odd
        mainLeftOddStyleIndex      = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  mainLeftBorder    , null);
        mainMiddleOddStyleIndex    = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  mainMiddleBorder  , null);
        mainRightOddStyleIndex     = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  mainRightBorder   , null);

        // Main Even
        mainLeftEvenStyleIndex     = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, mainLeftBorder    , null);
        mainMiddleEvenStyleIndex   = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, mainMiddleBorder  , null);
        mainRightEvenStyleIndex    = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, mainRightBorder   , null);

        // Bottom Odd
        bottomLeftOddStyleIndex    = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  bottomLeftBorder  , null);
        bottomMiddleOddStyleIndex  = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  bottomMiddleBorder, null);
        bottomRightOddStyleIndex   = addCellStyle(b, 0, mainFontIndex,   mainFillOddIndex,  bottomRightBorder , null);

        // Bottom Even
        bottomLeftEvenStyleIndex   = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, bottomLeftBorder  , null);
        bottomMiddleEvenStyleIndex = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, bottomMiddleBorder, null);
        bottomRightEvenStyleIndex  = addCellStyle(b, 0, mainFontIndex,   mainFillEvenIndex, bottomRightBorder , null);

        // Set the required styles to true so it does not run again
        defaultStylesApplied = true;
    }
}