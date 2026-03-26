/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that is used to build and XLSX file
 *                 Use this class to setup all data and metadata
 * @false-positive PMD.AvoidGlobalModifier  This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Builder {

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Flag to switch between shared and inline strings
    private Boolean     useSharedStrings = Constant.DEF_SHARED_STRINGS;

    // Set for the worksheet names to prevent duplicate names and to create the relationship XML file
    private Set<String> worksheetNames   = new Set<String>{};

    // Integer to track the number of shared strings, to prevent running the .size() unnecessarily
    private Integer     numSharedStrings = 0;

    // Store the number of worksheets in a variable to prevent running the .size() unnecessarily
    private Integer     numWorksheets    = 0;

    // Maps to track the number of columns and rows, to prevent running the .size() unnecessarily
    private Integer[]   worksheetNumColumnsList  = new Integer[]{};
    private Integer[]   worksheetNumRowsList     = new Integer[]{};

    // Map to track the number of cells in each row per worksheet, saves running the .size() method unnecessarily
    private Integer[][] worksheetRowNumCellsList = new Integer[][]{};

    // Map to track assigned column styles so new cells can take over the default
    private Integer[][] worksheetColumnStyleList = new Integer[][]{};

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Default filename in case no file name is given by the user
    public String      fileName         = Constant.DEF_FILE_NAME;


    /** **************************************************************************************************** **
     **                                    TOP LEVEL XML ELEMENT VARIABLES                                   **
     ** **************************************************************************************************** **/
    // Top level Xml Element for file "xl/sharedStrings.xml"
    public XmlElement.Sst              sharedStrings         = new XmlElement.Sst();

    // Top level Xml Element for file "xl/styles.xml"
    public XmlElementStyles.StyleSheet styleSheet            = new XmlElementStyles.StyleSheet();

    // Top level Xml Element for file "docProps/core.xml"
    public XmlElement.CoreProperties   coreProperties        = new XmlElement.CoreProperties();

    // Top level Xml Element for file "docProps/app.xml"
    public XmlElement.Properties       properties            = new XmlElement.Properties();

    // Top level Xml Element for file "xl/workbook.xml"
    public XmlElement.Workbook         workbook              = new XmlElement.Workbook();

    // Top level Xml Element for file "xl/worksheets/sheet[X].xml"
    public XmlElement.Worksheet[]      worksheets            = new XmlElement.Worksheet[]{};

    // Top level Xml Element for file "[Content_Types].xml"
    public XmlElement.Types            contentTypes          = new XmlElement.Types();

    // Top level Xml Element for file "_rels/.rels"
    public XmlElement.Relationships    relationships         = new XmlElement.Relationships(false);

    // Top level Xml Element for file "xl/_rels/workbook.xml.rels"
    public XmlElement.Relationships    workbookRelationships = new XmlElement.Relationships(true);


    /** **************************************************************************************************** **
     **                                              CONSTRUCTOR                                             **
     ** **************************************************************************************************** **/
    /**
     * @description You can create a builder without any sheets, but now it's your own responsibility
     */
    global Builder(){
        // Populate the default required styles for the builder. Excel requires a few basic styles to be present.
        // As our main if not only use case is Excel, it's best to just add these so you don't have to worry about it
        StylesBuilder.populateDefaultRequiredStyles(this);
    }


    /** **************************************************************************************************** **
     **                                   GLOBAL FILE INFO SETTER METHODS                                    **
     ** **************************************************************************************************** **/
    global void setUseSharedStrings(Boolean value){
        this.useSharedStrings = value;
    }

    global void setIncludeDefaultStyles(Boolean value){
        if(value){
            StylesBuilder.populateDefaultStyles(this);
        }
    }


    /** **************************************************************************************************** **
     **                                   GLOBAL FILE INFO SETTER METHODS                                    **
     ** **************************************************************************************************** **/
    // Boring setter methods
    global void setFileName(   String value){this.fileName    = value;}

    // Document detail setter methods
    global void setTitle(      String value){this.coreProperties.title       = value;}
    global void setSubject(    String value){this.coreProperties.subject     = value;}
    global void setDescription(String value){this.coreProperties.description = value;}
    global void addKeyword(    String value){this.coreProperties.keywords.add(value);}


    /** **************************************************************************************************** **
     **                                     XML ELEMENT GETTER METHODS                                       **
     ** **************************************************************************************************** **/
    @TestVisible
    private XmlElement.Col getColumn(Integer wi, Integer ci){

        // Prevent out of bounds by padding the worksheet
        padWorksheet(wi, ci, 0);

        // Create a new column if it doesn't exist yet
        if(this.worksheets[wi].cols.cols[ci] == null){
            this.worksheets[wi].cols.cols[ci] = new XmlElement.Col(ci);
        }
        return this.worksheets[wi].cols.cols[ci];
    }


    @TestVisible
    private XmlElement.Row getRow(Integer wi, Integer ri){

        // Prevent out of bounds by padding the worksheet
        padWorksheet(wi, 0, ri);

        return this.worksheets[wi].sheetData.rows[ri];
    }


    @TestVisible
    private XmlElement.Cell getCell(Integer wi, Integer ci, Integer ri){

        // Prevent out of bounds by padding the worksheet
        padWorksheet(wi, ci, ri);

        // Create a new cell if it doesn't exist yet
        if(this.worksheets[wi].sheetData.rows[ri].cells[ci] == null){
            this.addTextCell(wi,ci,ri,'');
        }
        return this.worksheets[wi].sheetData.rows[ri].cells[ci];
    }


    /** **************************************************************************************************** **
     **                                       PUBLIC GETTER METHODS                                          **
     ** **************************************************************************************************** **/

    // Method to get the highest worksheet index (Used for package building)
    public Integer getMaxWorksheetIndex(){
           return this.numWorksheets-1;
    }

    // Method to get the highest column index of all the worksheets (Used for column names)
    public Integer getMaxColumnIndex(){
        return BuildUtil.getMaxIntegerFromList(this.worksheetNumColumnsList);
    }

    // Method to get the highest row index of all the worksheets (Used for row name)
    public Integer getMaxRowIndex(){
        return BuildUtil.getMaxIntegerFromList(this.worksheetNumRowsList);
    }


    /** **************************************************************************************************** **
     **                                            SETTER METHODS                                            **
     ** **************************************************************************************************** **/
    /**
     * WORKBOOK SETTERS
     */
     /**
     * @description Method to add a worksheet to the builder
     * @param name The name of the worksheet
     */
    global Integer addWorksheet(String name){
            return addWorksheet(name, true);
    }


    /**
     * @description Method to add a worksheet to the builder
     * @param name                  The name of the worksheet
     * @param writeDimensionElement The flag to indicate if the write the dimension element
     */
    global Integer addWorksheet(String name, Boolean writeDimensionElement){

        // Assign the worksheet index for the new sheet, (Zero index so we can take the size for a new entry)
        Integer wi = this.worksheets.size();

        // validate the worksheet name is OK and sanitize as much as possible
        name = String.isBlank(name) ?
            String.format(Constant.DEF_SHEET_TITLE, new String[]{ (wi+1).toString()} ) :
            BuildUtil.sanitizeWorksheetName(name)
        ;

        // Validate the sheet does not exist yet
        if(this.worksheetNames.contains(name)){
            throw new BuildException(String.format(Constant.MSG_DUPLICATE_WORKSHEET, new String[]{name}));
        }

        // Add the worksheet name into the map and into the index or reverse lookup
        worksheetNames.add(name);

        // Add a worksheet
        this.Worksheets.add(new XmlElement.Worksheet(name, writeDimensionElement));

        // Add up the counters and add all the index counters
        this.numWorksheets = wi+1;
        this.worksheetNumColumnsList.add(0);
        this.worksheetNumRowsList.add(0);
        this.worksheetRowNumCellsList.add(new Integer[]{});
        this.worksheetColumnStyleList.add(new Integer[]{});

        // Add a Sheet element to the workbook element, this is for the workbook file
        this.workbook.sheets.sheets.add(new XmlElement.Sheet(wi,name));

        // Add a type override for the worksheet
        this.contentTypes.overrides.add(
            new XmlElement.TypeOverride(
                String.format(
                    Constant.CT_PATH_SHEET,
                    new String[]{wi.toString()}
                ),
                Constant.CT_WORKSHEET
            )
        );

        // Add the workbook relationship, note that we use the RID Offset as some relationships
        // already exists and these file Ids have to match
        this.workbookRelationships.relationships.add(new XmlElement.Relationship(
            String.format(
                'rId{0}',
                new String[]{(this.numWorksheets + Constant.WS_RID_OFFSET).toString()}
            ),
            Constant.NS_REL_WORKSHEET,
            String.format(Constant.REL_PATH_SHEET, new String[]{wi.toString()})
        ));

        // return the index so the calling class can use it
        return wi;
    }


    /**
     * WORKSHEET SETTERS
     */
    /**
     * @description Method to manually pad the worksheet to improve performance
     *              This method should only be used when you know the number of cells and rows
     *              or the Dimension Xml Element will be wrong
     */
    global void prePadWorksheet(Integer wi, Integer ci, Integer ri){
        this.padWorksheet(wi,ci,ri);
    }


    global void setVisible(Integer wi, Boolean state){
        this.workbook.sheets.sheets[wi].state = state ? 'visible' : 'hidden';
    }


    global void setTabColor(Integer wi, String colorCode){
        this.worksheets[wi].sheetPr.tabColor.rgb  = colorCode;
        this.worksheets[wi].sheetPr.tabColor.auto = false;
    }


    global void setAutoFilter(Integer wi, Boolean value){
        this.worksheets[wi].autoFilter = value;
    }


    global void setFreezeRows(Integer wi, Integer numberOfRows){
        // Input validation
        if(numberOfRows < 1){return;}

        // Freeze the rows
        this.worksheets[wi].sheetViews.sheetviews[0].pane.ySplit = numberOfRows;
    }


    global void setFreezeColumns(Integer wi, Integer numberOfColumns){
        // Input validation
        if(numberOfColumns < 1){return;}

        // Freeze columns in the worksheet
        this.worksheets[wi].sheetViews.sheetviews[0].pane.xSplit = numberOfColumns;
    }


    global void addTextCell(Integer wi, Integer ci, Integer ri, String v){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell data with the default column cell style applied
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            this.useSharedStrings,
            ci,
            ri,
            this.useSharedStrings ? this.getSharedStringIndex(v ?? '').toString() : v ?? '',
            worksheetColumnStyleList[wi][ci]
        );
    }


    global void addNumberCell(Integer wi, Integer ci, Integer ri, Integer v){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell data with the default column cell style applied
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            ci,
            ri,
            v,
            worksheetColumnStyleList[wi][ci]
        );
    }


    global void addNumberCell(Integer wi, Integer ci, Integer ri, Decimal v){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell data with the default column cell style applied
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            ci,
            ri,
            v,
            worksheetColumnStyleList[wi][ci]
        );
    }


    global void addBooleanCell(Integer wi, Integer ci, Integer ri, Boolean v){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell data with the default column cell style applied
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            ci,
            ri,
            v,
            worksheetColumnStyleList[wi][ci]
        );
    }


    global void addFormulaCell(Integer wi, Integer ci, Integer ri, Object v, String f){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell data with the default column cell style applied
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            ci,
            ri,
            v,
            f,
            worksheetColumnStyleList[wi][ci]
        );
    }


    // -------------------------------------------------------------------------------------
    //                      WITH STYLE INDEXES INCLUDED
    // -------------------------------------------------------------------------------------
    global void addTextCell(Integer wi, Integer ci, Integer ri, String v, Integer s){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Create the cell, takes about 900ms for 100k cells
        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(
            this.useSharedStrings,
            ci,
            ri,
            this.useSharedStrings ? this.getSharedStringIndex(v ?? '').toString() : v ?? '',
            s
        );
    }


    global void addNumberCell(Integer wi, Integer ci, Integer ri, Integer v, Integer s){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(ci,ri,v, s);
    }


    global void addNumberCell(Integer wi, Integer ci, Integer ri, Decimal v, Integer s){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(ci,ri,v, s);
    }


    global void addBooleanCell(Integer wi, Integer ci, Integer ri, Boolean v, Integer s){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(ci,ri,v, s);
    }


    global void addFormulaCell(Integer wi, Integer ci, Integer ri, Object v, String f, Integer s){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        this.worksheets[wi].sheetData.rows[ri].cells[ci] = new XmlElement.Cell(ci,ri,v,f,s);
    }
    // -------------------------------------------------------------------------------------


    global void addMergeCell(Integer wi, Integer startCi, Integer startRi, Integer endCi, Integer endRi){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi, endCi, endRi);

        // Add a merge cell with the start and the end
        this.worksheets[wi].mergeCells.mergeCells.add(
            new XmlElement.MergeCell(startCi, startRi, endCi, endRi)
        );
    }


    global void addHyperLink(Integer wi, Integer ci, Integer ri, String location, String display){

        // Apply padding so the sheet does not go out of bounds
        this.padWorksheet(wi,ci,ri);

        // Add the worksheet
        this.worksheets[wi].hyperlinks.hyperlinks.add(
            new XmlElement.Hyperlink(ci,ri,location,display)
        );
    }



    /**
     * ROW SETTERS
     */
    global void setRowStyle(Integer wi, Integer ri, Integer s){
        this.getRow(wi,ri).s = s;
    }


    global void setRowHeight(Integer wi, Integer ri, Decimal h){
        this.getRow(wi,ri).ht = h;
    }


    global void setRowHidden(Integer wi, Integer ri, Boolean v){
        this.getRow(wi,ri).hidden = v;
    }


    /**
     * COLUMN SETTERS
     */
    global void setColStyle(Integer wi, Integer ci, Integer s){
        this.getColumn(wi,ci).style = s;

        // Set the style index for the specified column in the worksheet
        worksheetColumnStyleList[wi][ci] = s;
    }


    global void setColWidth(Integer wi, Integer ci, Decimal w){
        this.getColumn(wi,ci).width = w;
    }


    global void setColHidden(Integer wi, Integer ci, Boolean h){
        this.getColumn(wi,ci).hidden = h;
    }


    /**
     * CELL SETTERS
     */
    global void setCellStyle(Integer wi, Integer ci, Integer ri,Integer s){
        this.getCell(wi,ci,ri).s = s;
    }



    /** *******************************************************************************
     *                              PRIVATE SUPPORT METHODS
     ** *******************************************************************************/
    private void padWorksheet(Integer wi, Integer ci, Integer ri){
        // Check if the worksheet index is out of bounds and add extra worksheets if required
        if(wi >= this.numWorksheets){
            for(Integer i = numWorksheets; i <= wi; i++){
                this.addWorksheet(null);
            }
        }

        // Check if the column index is out of bounds and add extra columns to pad properly
        if(ci >= this.worksheetNumColumnsList[wi]){
            for(Integer i = this.worksheetNumColumnsList[wi]-1; i < ci; i++){
                // Pad the column array with a null
                this.worksheets[wi].cols.cols.add(null);
            }
            // Update the number of columns counter
            this.worksheetNumColumnsList[wi] = ci + 1;
        }

        // Faster to set as a variable
        Integer numRows = this.worksheetNumRowsList[wi];

        // Check if the row index is out of bounds and add extra rows to pad properly [xx]
        if(ri >= numRows){
            for(Integer i = numRows; i <= ri; i++){

                // Add the row and populate the row index with the current number of rows
                // Pad with null values to not create rows we don't need
                this.worksheets[wi].sheetData.rows.add(null);

                // Set the number of cells for each row in the worksheet
                this.worksheetRowNumCellsList[wi].add(0);
            }
            // Update the number of rows
            this.worksheetNumRowsList[wi] = ri+1;
        }

        // Extract the number of cells in the current row
        Integer numCells = (ri > 0) ? this.worksheetRowNumCellsList[wi][ri] : 0;

        // Now that the columns and rows are added check if the cell is out of bounds
        if(ci >= numCells){

            // Check we have a row at the requested index and if not add the row
            if(this.worksheets[wi].sheetData.rows[ri] == null){
                this.worksheets[wi].sheetData.rows[ri] = new XmlElement.Row(ri);
            }

            // Pad the cells with null values
            for(Integer i=numCells; i<=ci;i++){
                this.worksheets[wi].sheetData.rows[ri].cells.add(null);
                
                // Add a null value for each column style so don't have out of bounds later
                this.worksheetColumnStyleList[wi].add(null);
            }

            // Up the cell counter
            this.worksheetRowNumCellsList[wi][ri] = ci+1;
        }
    }


    private Integer getSharedStringIndex(String v){
        if(!this.sharedStrings.sharedStringsMap.containsKey(v)){
            this.sharedStrings.sharedStringsMap.put(v,this.numSharedStrings);
            this.numSharedStrings++;
            return this.numSharedStrings-1;
        }
        return this.sharedStrings.sharedStringsMap.get(v);
    }

}