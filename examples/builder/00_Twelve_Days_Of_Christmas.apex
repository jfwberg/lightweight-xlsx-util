/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Example to answer the age old questions... How many gifts did my true love gave to me
 *                 after twelve days of Christmas... or 30 or 60 or N days of Christmas...
 */
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Configure the builder to use the shared strings index instead of inline strings
b.setUseSharedStrings(true);

// Set the destination folder and the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_twelve_days_of_christmas.xlsx' );

// Set file properties
b.setTitle('Twelve Days of Christmas (' +xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('Christmas quiz');
b.setDescription('Let\'s find out how many presents we get...');
b.addKeyword('Christmas');
b.addKeyword('Quiz');

// Create fonts (Builder, Size, Name, Color, Bold, Italic, Underline)
Integer mainFontIndex            = xlsx.StylesBuilder.addFont(b, 12, 'Consolas', '242424', false, false, false);
Integer headerFontIndex          = xlsx.StylesBuilder.addFont(b, 12, 'Consolas', '03234D', true,  false, false);
Integer headerTotalFontIndex     = xlsx.StylesBuilder.addFont(b, 12, 'Consolas', '300B60', true,  true,  false);

// Create fills (Builder, patternType, foreground color, background color)
// (based on SF colors https://www.lightningdesignsystem.com/guidelines/color/our-color-system/)
Integer rowHeaderFillIndex       = xlsx.StylesBuilder.addFill(b, 'lightGray', 'FE8F7D', 'FE5C4C');
Integer colHeaderFillIndex       = xlsx.StylesBuilder.addFill(b, 'lightGray', '91DB8B', '3BA755');
Integer totalsFillIndex          = xlsx.StylesBuilder.addFill(b, 'lightGray', 'F9E3B6', 'CA8501');
Integer mainFillIndex            = xlsx.StylesBuilder.addFill(b, 'lightGray', 'E5E5E5', '939393');

// Add a border (builder, left, right, top, bottom)
Integer thinRightBorder = xlsx.StylesBuilder.addBorder(b, null,
    xlsx.StylesBuilder.borderConfig('thin', '0000FF'), 
    null, null
);

// Add a border (builder, left, right, top, bottom)
Integer mediumBottomBorder = xlsx.StylesBuilder.addBorder(b,null, null, null,
    xlsx.StylesBuilder.borderConfig('medium', '0000FF')
);

// Add a border (builder, left, right, top, bottom)
Integer mediumRightBorder = xlsx.StylesBuilder.addBorder(b, null,
    xlsx.StylesBuilder.borderConfig('medium', '0000FF'), 
    null, null
);

// Add a border (builder, left, right, top, bottom)
Integer fullBorderIndex = xlsx.StylesBuilder.addBorder(b,
    xlsx.StylesBuilder.borderConfig('medium', '0000FF'), 
    xlsx.StylesBuilder.borderConfig('medium', '0000FF'), 
    xlsx.StylesBuilder.borderConfig('medium', '0000FF'), 
    xlsx.StylesBuilder.borderConfig('medium', '0000FF')
);

// Create Style indexes (Builder, NumberFormatId, FontId, FillId, BorderId)
Integer mainStyleIndex           = xlsx.StylesBuilder.addCellStyle(b, 0, mainFontIndex,        mainFillIndex,      thinRightBorder,    null);

Integer rowHeaderStyleIndex      = xlsx.StylesBuilder.addCellStyle(b, 0, headerFontIndex,      rowHeaderFillIndex, mediumBottomBorder, null);
Integer rowHeaderTotalStyleIndex = xlsx.StylesBuilder.addCellStyle(b, 0, headerTotalFontIndex, rowHeaderFillIndex, mediumBottomBorder, null);

Integer colHeaderStyleIndex      = xlsx.StylesBuilder.addCellStyle(b, 0, headerFontIndex,      colHeaderFillIndex, mediumRightBorder,  null);
Integer colHeaderTotalStyleIndex = xlsx.StylesBuilder.addCellStyle(b, 0, headerTotalFontIndex, colHeaderFillIndex, mediumRightBorder,  null);

Integer totalStyleIndex          = xlsx.StylesBuilder.addCellStyle(b, 0, headerTotalFontIndex, totalsFillIndex,    0,                  null);
Integer fullTotalStyleIndex      = xlsx.StylesBuilder.addCellStyle(b, 0, headerTotalFontIndex, totalsFillIndex,    fullBorderIndex,    null);

// Let's start with 12 days of Christmas
buildNdaysOfChristmasWorksheet(
    b,
    new String[]{
        'Partridge','Turtle Dove','French Hen','Colly Bird','Golden Ring','Geese','Swan','Maid','Lady','Lord','Piper','Drummer'
    }
);

// Let's continue with 30 days of Christmas
buildNdaysOfChristmasWorksheet(
    b,
    new String[]{
        'Partridge','Turtle Dove','French Hen','Colly Bird','Golden Ring','Geese','Swan','Maid','Lady','Lord','Piper','Drummer',
        'Plant','Tree','Fridge','Pillow','Sweater','Neon Sign','Wallet','Multitool','Airtag','Puzzle','Jacket','Mittens','Shoes','Socks','Toys','Necklace','Alexa','Lego'
    }
);

// Let's continue with 60 days of Christmas
buildNdaysOfChristmasWorksheet(
    b,
    new String[]{
        'Partridge','Turtle Dove','French Hen','Colly Bird','Golden Ring','Geese','Swan','Maid','Lady','Lord','Piper','Drummer',
        'Plant','Tree','Fridge','Pillow','Sweater','Neon Sign','Wallet','Multitool','Airtag','Puzzle','Jacket','Mittens','Shoes','Socks','Toys','Necklace','Alexa','Lego',
        'Partridge','Turtle Dove','French Hen','Colly Bird','Golden Ring','Geese','Swan','Maid','Lady','Lord','Piper','Drummer',
        'Plant','Tree','Fridge','Pillow','Sweater','Neon Sign','Wallet','Multitool','Airtag','Puzzle','Jacket','Mittens','Shoes','Socks','Toys','Necklace','Alexa','Lego'
    }
);


System.debug(
    insertDocumentAndGetDownloadLink(
        xlsx.Build.asDocument(b)
    )
);


/** **************************************************************************************************** **
 **                                       PRIVATE SUPPORT METHODS                                        **
 ** **************************************************************************************************** **/
/**
 * @description Method to insert a Document and retrieve its download link
 * @param  d The Document to be inserted
 * @return   The download link for the inserted Document
 */
private static String insertDocumentAndGetDownloadLink(Document d){
    insert as user d;
    return URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + d.Id;
}


/**
 * N Days(12) of Christmas Example: An Excel sheet to answer the age old Question:
 * How many presents did my true love gave to me after N(12) days?
 */
private static void buildNdaysOfChristmasWorksheet(xlsx.Builder b, String[] gifts){

    // Get the number of gifts
    Integer numberOfGifts = gifts.size();

    // Create the worksheet name
    String worksheetName = numberOfGifts + ' Days of Christmas';

    // Get the worksheet index when adding it to the worksheet array
    Integer wi = b.addWorksheet(worksheetName);
        
    // Give our tab a festive color (random color)
    b.setTabColor(wi, xlsx.CommonUtil.randomHtmlHexColorCode());

    // Freeze the header row and header column
    b.setFreezeRows(   wi, 1);
    b.setFreezeColumns(wi, 1);

    // Set the width for the first and last column
    b.setColWidth(wi, 0,               11);
    b.setColWidth(wi, numberOfGifts+1, 11);
    
    // Add the first cell in the column header as an empty value
    b.addTextCell(wi,0,0,null,rowHeaderStyleIndex);

    // Populate the gift names as header values into the first row
    for(Integer i=1; i<=numberOfGifts; i++){

        // Set the column width
        b.setColWidth(wi, i, (gifts[i-1].length() * 1.35));
        
        // Add a header cell with text
        b.addTextCell(wi,i,0,gifts[i-1],rowHeaderStyleIndex);
    }

    // Set the postfix for the day of Christmas, start with th
    String postFix = 'st';

    // Add the day in the row
    for(Integer i=1; i<=numberOfGifts; i++){
        
        // Add the day to the cell
        b.addTextCell(wi, 0, i, i + postFix,colHeaderStyleIndex);
        
        // Update the postfix accordingly until after 3, than do nothing
        if(i>3){}
        else if(i==1){postFix = 'nd';}
        else if(i==2){postFix = 'rd';}
        else if(i==3){postFix = 'th';}
    }

    // Add the Christmas gifts for each day
    for(Integer i = 1; i<numberOfGifts+1;i++){
        
        // Add the number cells
        for(Integer j = 1; j<=i;j++){
            b.addNumberCell(wi,j,i, j,mainFontIndex);
        }

        // Add empty cells for the style only
        for(Integer j = i+1; j<numberOfGifts+1;j++){
            b.addTextCell(wi, j, i, null, mainFontIndex);
        }
    }

    // Add the totals row
    Integer totalRowIndex = numberOfGifts+1;
    b.addTextCell(wi, 0, totalRowIndex, 'Gift Total', colHeaderTotalStyleIndex);
    

    // Add the formulas to add up the number of presents of each type
    for(Integer columnIndex = 1; columnIndex<=numberOfGifts; columnIndex++){
        
        // Get the column names i + the first column as offset
        String columnStart = xlsx.CommonUtil.cellName(columnIndex, 1);
        String columnEnd   = xlsx.CommonUtil.cellName(columnIndex, numberOfGifts);
        
        // Calculate the total
        Integer typeTotal = (numberOfGifts+1 - columnIndex) * columnIndex;
        
        // Add the formula cell 
        b.addFormulaCell(wi, columnIndex,totalRowIndex, typeTotal,'SUM( '+ columnStart +':'+ columnEnd +')',totalStyleIndex);
    }

    // The full total of gifts
    Integer total = 0;

    // Add the daily total column at the end (column is automatically created using this method)
    b.addTextCell(wi, numberOfGifts + 1, 0, 'Day Total', rowHeaderTotalStyleIndex);

    // Add the total for each column (start at 1 to ignore the header column (A))
    for(Integer rowIndex=1; rowIndex<=numberOfGifts; rowIndex++){

        // The start cell is 1 (column B) and the end cell is the Last column
        String rowStartCell = xlsx.CommonUtil.cellName(1,rowIndex);
        String rowEndCell   = xlsx.CommonUtil.cellName(numberOfGifts, rowIndex);

        // Calculate the day total
        Integer dayTotal = 0;
        for(Integer j=0; j< rowIndex; j++){
            dayTotal+=j+1;
        }

        // Calculate the overall total
        total+=dayTotal;

        // Add the formula cell in the column after the last day of christmas
        b.addFormulaCell(wi, numberOfGifts+1, rowIndex, dayTotal, 'SUM('+rowStartCell+':'+rowEndCell+')', totalStyleIndex);
    }

    // Add the total after the last day of christmas
    b.addNumberCell(wi, numberOfGifts+1, numberOfGifts+1, total, fullTotalStyleIndex);    
}