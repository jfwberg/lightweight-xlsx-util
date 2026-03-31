/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the classes that represent XML Elements
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 * @false-positive CognitiveComplexity      Way over the threshold, but this is because of the nature
 *                                          of lots of small XML writing statements with null cells.
 *                                          Unless you split into many different files, the complexity
 *                                          will be very high, but it's not difficult to read.
 * @false-positive ExcessiveParameterList   I need to find a nicer way for the massive amount of parameters.
 *                                          Unfortunately there are many of them and this is the easiest for now.
 * @false-positive ExcessiveClassLength     It's a long class, will potentially split it up in the future but
 *                                          at this stage is the easiest for understanding to keep all elements in
 *                                          the same class
 */
@SuppressWarnings('PMD.OneDeclarationPerLine, PMD.CognitiveComplexity, PMD.ExcessiveParameterList, PMD.ExcessiveClassLength')
public with sharing class XmlElement {

    /** **************************************************************************************************** **
     **                                      SHARED STRINGS XML ELEMENTS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the Relationships Xml Element
     * @file        sharedStrings.xml
     * @path        sst
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sst_topic_ID0E4UT5.html
     */
    public with sharing class Sst implements IXmlElement{

        // Map that holds the shared strings
        public Map<String,Integer> sharedStringsMap = new Map<String,Integer>();

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            // Write sst element
            x.writeStartElement(null, 'sst', null);
            x.writeDefaultNamespace(Constant.NS_SPREADSHEET_ML);

            // Write the strings
            for(String key : this.sharedStringsMap.keySet()){
                if(key == null){continue;}
                x.writeStartElement(null, 'si', null);
                x.writeStartElement(null, 't', null);
                x.writeCharacters(key);
                x.writeEndElement();
                x.writeEndElement();
            }

            // Close the sst element
            x.writeEndElement();
        }
    }


    /** **************************************************************************************************** **
     **                                          CORE XML ELEMENTS                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the coreProperties Xml Element
     * @file        core.xml
     * @path        coreProperties
     * @docs        https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Core_topic_ID0ED3CO.html
     */
    public with sharing class CoreProperties implements IXmlElement{

        // Child elements
        private String   creator  = Constant.CREATOR;
        private Integer  revision = Constant.REVISION;

        // Builder updatable values
        public String   title     = Constant.DEF_TITLE;
        public String   subject;
        public String   description;
        public String[] keywords  = new String[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            // Write properties
            x.writeStartElement(null, 'coreProperties', null);
            x.writeDefaultNamespace(    Constant.NS_MTD_CORE_PROP);
            x.writeNamespace('dc',      Constant.NS_DC_ELMTS);
            x.writeNamespace('dcterms', Constant.NS_DC_TERMS);
            x.writeNamespace('xsi',     Constant.NS_XSI);

            // Write created
            x.writeStartElement('dcterms', 'created', '');
            x.writeAttribute('xsi', '', 'type', 'dcterms:W3CDTF');
            x.writeCharacters(Constant.NOW.format(Constant.ISO_8601_FORMAT));
            x.writeEndElement();

            // Write single elements
            BuildUtil.writeSingleXmlElement(x, 'dc', 'title',       this.title ?? '');
            BuildUtil.writeSingleXmlElement(x, 'dc', 'subject',     this.subject ?? '');
            BuildUtil.writeSingleXmlElement(x, 'dc', 'creator',     this.creator ?? '');
            BuildUtil.writeSingleXmlElement(x, null, 'keywords',    String.join(this.keywords, ', ') ?? '');
            BuildUtil.writeSingleXmlElement(x, 'dc', 'description', this.description ?? '');
            BuildUtil.writeSingleXmlElement(x, null, 'revision',    this.revision.toString());

            // End of Properties
            x.writeEndElement();
        }
    }


    /** **************************************************************************************************** **
     **                                           APP XML ELEMENTS                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the Properties Xml Element
     * @file        app.xml
     * @path        Properties (note the capital P)
     * @docs        https://c-rex.net/samples/ooxml/e1/Part1/OOXML_P1_Fundamentals_Extended_topic_ID0EFIDO.html
     */
    public with sharing class Properties implements IXmlElement{

        // Child elements
        public String company     = Constant.COMPANY_NAME;
        public String application = Constant.APP_NAME;

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            // Start of Properties
            x.writeStartElement(null, 'Properties', null);
            x.writeDefaultNamespace(Constant.NS_OFFICE_DOC_PROP);

            // Company and app
            BuildUtil.writeSingleXmlElement(x, null, 'Company',     this.company    );
            BuildUtil.writeSingleXmlElement(x, null, 'Application', this.application);

            // End of Properties
            x.writeEndElement();
        }
    }


    /** **************************************************************************************************** **
     **                                         WORKBOOK XML ELEMENTS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the workbook Xml Element
     * @file        workbook.xml
     * @path        workbook
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_Workbook_topic_ID0E1C63.html
     */
    public with sharing class Workbook implements IXmlElement{

        // Child elements
        public Sheets sheets = new Sheets();

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            // Write workbook element
            x.writeStartElement(null, 'workbook', null);
            x.writeDefaultNamespace(Constant.NS_SPREADSHEET_ML);
            x.writeNamespace('r', Constant.NS_OFFICE_DOC_RELS);
            this.sheets.writeXml(x);
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the sheets Xml Element
     * @file        workbook.xml
     * @path        workbook > sheets
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheets_topic_ID0EJUG4.html
     */
    public with sharing class Sheets implements IXmlElement{

        // Child elements
        public Sheet[] sheets = new Sheet[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(x, null, 'sheets', this.sheets);
        }
    }


    /**
     * @description Data structure representing the sheet Xml Element
     * @file        workbook.xml
     * @path        workbook > sheets > sheet
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheet_topic_ID0EFLG4.html#topic_ID0EFLG4
     */
    public with sharing class Sheet implements IXmlElement{

        // Worksheet index
        private Integer wi;

        // Attributes
        public String name;

        // State either "visible" or "hidden", visible is the default
        public String state;

        /**
         * @description Main constructor for the Sheet class
         * @param wi    The worksheet index
         * @param name  The worksheet name
         */
        public Sheet(Integer wi, String name){
            this.name = name;
            this.wi   = wi;
        }

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            // Write sheet element
            x.writeEmptyElement(null,    'sheet',   null);
            x.writeAttribute(null, null, 'name',    this.name);

            // Write the sheet Id, note here the the rId need to match the rId in the worksheet.rels file, hence we have an offset
            x.writeAttribute(null, null, 'sheetId', BuildUtil.rowNames[wi + Constant.WS_RID_OFFSET]);
            x.writeAttribute('r',  '',   'id',      String.format('rId{0}', new String[]{BuildUtil.rowNames[wi + Constant.WS_RID_OFFSET]}));

            // Write the state if specified
            if(this.state != null){
                x.writeAttribute(null, null, 'state',   this.state);
            }
        }
    }


    /** **************************************************************************************************** **
     **                                        WORKSHEET XML ELEMENTS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the worksheet Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_worksheet_topic_ID0EUZM5.html#topic_ID0EUZM5
     */
    public with sharing class Worksheet implements IXmlElement{

        // Keep track of the max row and the max column to calculate the dimensions of the worksheet
        private Integer lastRowId = 0;
        private Integer lastColId = 0;

        // By default write the dimension element, this element allows for optimization
        // This is purely added for easy apex unit testing purposes, there is no reason
        // to not write this element
        private Boolean writeDimensionElement = true;

        /**
         * Sheet configuration variables
         */
        // The name of the worksheet
        public final String name;


        /**
         * ATTRIBUTES
         */
        // Disable auto filter
        public Boolean autoFilter = false;


        /**
         * CHILD ELEMENTS
         */
        // Sheet properties
        public SheetPr sheetPr = new sheetPr();

        // Sheet views
        public SheetViews sheetViews = new SheetViews();

        // Sheet formatting properties
        public SheetFormatPr sheetFormatPr = new SheetFormatPr();

        // The columns in this worksheet
        public Cols cols = new Cols();

        // The sheet data (Contains the rows / cells)
        public SheetData sheetData = new SheetData();

        // The page margins
        public PageMargins pageMargins = new PageMargins();

        // Any hyperlinked cells go in here
        public Hyperlinks hyperlinks = new Hyperlinks();

        // Any merge cells go in here
        public MergeCells mergeCells = new MergeCells();


        /**
         * @description Constructor for sheets without a dimension element
         * @param name  The name of the worksheet
         */
        public Worksheet(String name, Boolean writeDimensionElement){
            this.name = name;
            this.writeDimensionElement = writeDimensionElement;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            // Finalize any actions that require the sheet to be completed
            this.finalizeWorksheet();

            // Write the start of the worksheet and the namespaces
            x.writeStartElement(null, 'worksheet', null);
            x.writeDefaultNamespace(Constant.NS_SPREADSHEET_ML);
            x.writeNamespace('r', Constant.NS_OFFICE_DOC_RELS);

            // Write the sheet properties
            this.sheetPr.writeXml(x);

            // Write the sheet dimensions, these should be calculated at the end once all data has been added
            if(this.writeDimensionElement){
                new Dimension(
                    this.lastColId,
                    this.lastRowId
                ).writeXml(x);
            }

            // Write the sheet views
            this.sheetViews.writeXml(x);

            // Write the sheet formatting properties
            this.sheetFormatPr.writeXml(x);

            // Write the columns if any are present
            this.cols.writeXml(x);

            // Write sheet data
            this.sheetData.writeXml(x);

            // Write an auto filter on the first row
            if(this.autoFilter){
                new AutoFilter(
                    0,
                    0,
                    this.lastColId,
                    0
                ).writeXml(x);
            }

            // Write the mergecells
            this.mergeCells.writeXml(x);

            // Write the hyperlinks
            this.hyperlinks.writeXml(x);

            // Write the page margins - Breaks when added?
            this.pageMargins.writeXml(x);

            // End worksheet
            x.writeEndElement();
        }


        /**
         * @description Method for cleaning up any empty rows and calculating
         *              the final dimensions of the worksheet.
         */
        private void finalizeWorksheet(){

            // Reverse read the rows, to validate the true dimensions based on the last populated cell
            // This is to compensate for any improper use the padding methods.
            // This is a guard rail that tidies up the worksheet properly
            for(Integer ri= this.sheetData.rows.size()-1; ri >= 0; ri--){

                // If the row is null, it can be removed
                if(this.sheetData.rows[ri] == null){
                    continue;
                }

                // Indicate if a row has to be removed (remove row if all values are null, i.e. there are no cells)
                Boolean removeRow = true;

                // Reverse loop through the cells as we can stop as soon as we found a cell value
                for (Integer ci = this.sheetData.rows[ri].cells.size() - 1; ci >= 0 ; ci--) {

                    // Check if there are only null values, if so this row can be deleted
                    if(this.sheetData.rows[ri].cells[ci] !=null){

                        // If it is the last row Id, set the last row id
                        if(ri > lastRowId ){
                            lastRowId = ri;
                        }

                        // If it is the last column in the row and larger than previous rows
                        // update the last column index as this is now the largest
                        if(ci > lastColId){
                            lastColId = ci;
                        }

                        // A cell has been found so the row does not have to be removed
                        removeRow = false;

                        // As soon as a value has been found this is the last value in the row so continue
                        break;
                    }
                }

                // If there are only nulls in the last row, delete the row
                if(removeRow){
                    this.sheetData.rows[ri]=null;
                    continue;
                }
            }
        }
    }


    /**
     * @description Data structure representing the sheetPr Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetPr
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheetPr_topic_ID0EQOG5.html#topic_ID0EQOG5
     */
    public with sharing class SheetPr implements IXmlElement{

        // Child elements
        public TabColor tabColor = new TabColor();

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(   null, 'sheetPr',    null);
            if(this.tabColor != null){tabColor.writeXml(x);}
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the tabColor Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetPr > tabColor
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_tabColor_topic_ID0ECGL5.html#topic_ID0ECGL5
     */
    public with sharing class TabColor implements IXmlElement{

        // Auto color
        public Boolean auto = true;

        // Standard Alpha Red Green Blue color value (ARGB) 4 hex characters...?
        public String rgb;

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'tabColor', null);
            if(this.auto         ){ x.writeAttribute(null, null, 'auto', 'true'  );}
            if(this.rgb   != null){ x.writeAttribute(null, null, 'rgb',  this.rgb);}
        }
    }


    /**
     * @description Data structure representing the dimension Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > dimension
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_dimension_topic_ID0EZ2X4.html
     */
    public with sharing class Dimension implements IXmlElement{

        private Integer ci;
        private Integer ri;

        /**
         * @description Default constructor
         * @param ci The column index
         * @param ri The row index
         */
        public Dimension(Integer ci, Integer ri){
            this.ci = ci;
            this.ri = ri;
        }

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'dimension', null);
            x.writeAttribute(null, null, 'ref', 'A1:' + BuildUtil.getCellName(ci,ri));
        }
    }


    /**
     * @description Data structure representing the sheetViews Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetViews
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheetViews_topic_ID0ERWJ5.html#topic_ID0ERWJ5
     */
    public with sharing class SheetViews implements IXmlElement{

        // Create list of sheetviews with a single sheetview in here
        public SheetView[] sheetviews = new SheetView[]{
            new SheetView()
        };


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(x, null, 'sheetViews', this.sheetviews);
        }
    }


    /**
     * @description Data structure representing the XXX sheetView Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetViews > sheetView
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheetView_topic_ID0ELLI5.html
     */
    public with sharing class SheetView implements IXmlElement{

        // Child element pane
        public Pane pane = new Pane();

        // Child selection elements
        private Selection[] selections = new  Selection[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            // Write the sheetview element
            x.writeStartElement(   null, 'sheetView',      null);
            x.writeAttribute(null, null, 'workbookViewId', '0');

            // Only write the pane element if required
            if(this.pane.ySplit != null || this.pane.xSplit != null){

                // Write the pane element
                this.pane.writeXml(x);

                // Rows frozen only
                if(this.pane.ySplit != null && this.pane.xSplit == null){

                    // Write the selection element
                    this.selections.add(new Selection('bottomLeft', 0, this.pane.ySplit));

                // Columns frozen only
                }else if(this.pane.ySplit == null && this.pane.xSplit != null){

                    // Write the selection element
                    this.selections.add(new Selection('topRight',  this.pane.xSplit,0));

                // Both rows and columns are frozen
                }else {
                    // Write the selection element
                    this.selections.add(new Selection('topRight',    this.pane.xSplit, 0));
                    this.selections.add(new Selection('bottomLeft',  0,                this.pane.ySplit));
                    this.selections.add(new Selection('bottomRight', this.pane.xSplit, this.pane.ySplit));
                }

            // Nothing select so add the default selection
            }else{
                // Return a new list
                this.selections = new Selection[]{new Selection(null, 0, 0)};
            }

            // Write the selection elements
            for(Integer i=0, max = this.selections.size(); i<max;i++){
                this.selections[i].writeXml(x);
            }

            // End sheetView
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the pane Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetViews > sheetView > pane
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_pane_topic_ID0E1NA5.html
     */
    public with Sharing class Pane implements IXmlElement{

        // Number of rows
        public Integer ySplit;

        // Number of columns
        public Integer xSplit;

        // Columns only ySplit,0 - rows only 0,xSplit, both rows and columns xSplit,ySplit
        private String topLeftCell;

        // Columns only "topRight", rows only "bottomLeft", both rows and columns "bottomRight"
        private String activePane;


        /**
         * @description Method to calculate the values for teh top left cell and the active pane
         */
        private void setTopLeftCellAndActivePane(){
            // Rows frozen only
            if(ySplit != null && xSplit == null){
                this.topLeftCell = BuildUtil.getCellName(
                    0,
                    this.ySplit == 0 ? 0 : this.ySplit
                );
                this.activePane  = 'bottomLeft';

            // Columns frozen only
            }else if(ySplit == null && xSplit != null){
                this.topLeftCell = BuildUtil.getCellName(
                    this.xSplit == 0 ? 0 : this.xSplit,
                    0
                );
                this.activePane  = 'topRight';

            // Both rows and columns
            }else{
                this.topLeftCell = BuildUtil.getCellName(
                    this.xSplit == 0 ? 0 : this.xSplit,
                    this.ySplit == 0 ? 0 : this.ySplit
                );
                this.activePane  = 'bottomRight';
            }
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            // Only write the pane element if required
            if(ySplit != null || xSplit != null){

                // Calculate the values for the top left cell and the active pane
                this.setTopLeftCellAndActivePane();

                // Write the Pane element
                x.writeEmptyElement(null, 'pane', null);

                // Write the ySplit (rows)
                if(ySplit != null){
                    x.writeAttribute(null, null, 'ySplit', this.ySplit.toString());
                }

                // Write the xSplit (columns)
                if(xSplit != null){
                    x.writeAttribute(null, null, 'xSplit', this.xSplit.toString());
                }

                // Write the top left cell and active pane
                x.writeAttribute(null, null, 'topLeftCell', this.topLeftCell);
                x.writeAttribute(null, null, 'activePane',  this.activePane);
                x.writeAttribute(null, null, 'state',       'frozen');
            }
        }
    }


    /**
     * @description Data structure representing the selection Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetViews > sheetView > selection
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_selection_topic_ID0EGOF5.html
     */
    public with sharing class Selection implements IXmlElement{

        String pane;
        Integer ci;
        Integer ri;

        /**
         * @description Default constructor
         * @param pane  The name of the pane
         * @param ci    The Column index
         * @param ri    The Row index
         */
        public Selection(String pane, Integer ci, Integer ri){
            this.pane = pane;
            this.ci = ci;
            this.ri = ri;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            x.writeEmptyElement(null, 'selection', null);

            if(this.pane != null){x.writeAttribute(null, null, 'pane', this.pane);}

            x.writeAttribute(null, null, 'activeCell', BuildUtil.getCellName(ci,ri));
            x.writeAttribute(null, null, 'sqref',      BuildUtil.getCellName(ci,ri));
        }
    }


    /**
     * @description Data structure representing the sheetFormatPr Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetViews > sheetView > sheetFormatPr
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_selection_topic_ID0EGOF5.html
     */
    public with sharing class SheetFormatPr implements IXmlElement{

        // Default column width in points
        Decimal defaultColWidth  = 8.11;

        // Default row height in points
        Decimal defaultRowHeight = 14.4;

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'sheetFormatPr', null);
            x.writeAttribute(null, null, 'defaultColWidth',  this.defaultColWidth.setScale(2).toString());
            x.writeAttribute(null, null, 'defaultRowHeight', this.defaultRowHeight.setScale(2).toString());
        }
    }


    /**
     * @description Data structure representing the cols Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > cols
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_cols_topic_ID0E5XR4.html#topic_ID0E5XR4
     */
    public with sharing class Cols implements IXmlElement{

        // List of columns
        public Col[] cols = new Col[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(
                x, null, 'cols', this.cols
            );
        }
    }


    /**
     * @description Data structure representing the col Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > cols > col
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_col_topic_ID0ELFQ4.html#topic_ID0ELFQ4
     */
    public with sharing class Col implements IXmlElement{

        /**
         * CONFIGURATION VARIABLES
         */
        private Integer ci;

        /**
         * ATTRIBUTES
         */
        // Default style Index for the affected column
        public Integer style;

        // Width related attributes
        public Decimal width;

        // Flag indicating if the affected column(s) are hidden on this worksheet.
        public Boolean hidden;

        /**
         * @description Main constructor
         * @param ci    The (zero based) column index
         */
        public Col(Integer ci){
            this.ci = ci;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'col', null);
            x.writeAttribute(null, null, 'min',         BuildUtil.rowNames[this.ci]);
            x.writeAttribute(null, null, 'max',         BuildUtil.rowNames[this.ci]);
            x.writeAttribute(null, null, 'width',       (this.width !=null ? this.width.setScale(2) : 8.11).toString());

            if(this.width != null){
                x.writeAttribute(null, null, 'customWidth', '1');
            }

            if(this.style != null){
                x.writeAttribute(null, null, 'style', style.toString());
            }

            if(this.hidden != null){
                x.writeAttribute(null, null, 'hidden','true');
            }
        }
    }


    /**
     * @description Data structure representing the sheetData Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetData
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_sheetData_topic_ID0E32F5.html
     */
    public with sharing class SheetData implements IXmlElement{

        // List of rows in this worksheet, always have at least 1 row
        // There don't have to be cells, but at least one row to be valid
        public Row[] rows = new Row[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(x, null, 'sheetData', this.rows);
        }
    }


    /**
     * @description Data structure representing the row Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetData > row
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_row_topic_ID0EIKD5.html#topic_ID0EIKD5
     */
    public with sharing class Row implements IXmlElement{

        // Row Index
        private Integer ri;

        /**
         * ATTRIBUTES
         */
        // Style Index to style record for the row (only applied if customFormat attribute is 'true')
        public Integer s;

        // Row height measured in point size. There is no margin padding on row height
        public Decimal ht;

        // 'true' if the row is hidden
        public Boolean hidden;

        // Child elements
        public Cell[] cells = new Cell[]{};

        /**
         * @description Basic constructor with a row index
         * @param ri    The row index starting at 0
         */
        public Row(Integer ri){
            this.ri = ri;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'row', null);
            x.writeAttribute(null, null, 'r',                BuildUtil.rowNames[this.ri]);

            if(this.s != null){
                x.writeAttribute(null, null, 's',            this.s.toString());
                x.writeAttribute(null, null, 'customFormat', '1');
            }

            if(this.ht != null){
                x.writeAttribute(null, null, 'ht',           ht.setScale(2).toPlainString());
                x.writeAttribute(null, null, 'customHeight', '1');
            }

            // If you set hidden to '1' instead of 'true' you'll get an heap size error above 200k cells ¯\_(ツ)_/¯
            if(this.hidden != null){
               x.writeAttribute(null, null, 'hidden', 'true');
            }

            // Write the child cells
            for (Integer i=0, max=this.cells.size(); i < max; i++) {
                this.cells[i]?.writeXml(x);
            }

            // End element r
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the c Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > sheetData > row > c
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_c_topic_ID0E1XM4.html#topic_ID0E1XM4
     * @false-positive ApexDoc There are too many similar child methods in this class
     */
    @SuppressWarnings('PMD.ApexDoc')
    public with sharing class Cell implements IXmlElement{

        // Config variables
        private final Integer ci;
        private final Integer ri;

        // Attributes
        // Style index
        public Integer s;

        // Data type (b (boolean), e (error), n (number), s (shared string), str (formula))
        // inlineStr value is in <is> element
        private final String t;

        // Value
        private final String v;

        /**
         * CHILD ELEMENTS
         */
        // Formula
        private final String f;


        /**
         * CONSTRUCTORS
         */
        // Constructor: Text value
        public Cell(Boolean useSharedStrings, Integer ci, Integer ri, String v){
            this.v  = v;
            this.ci = ci;
            this.ri = ri;
            this.t  = useSharedStrings ? 's' : 'inlineStr';
        }


        // Constructor: Number value
        public Cell(Integer ci, Integer ri, Integer v){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'n';
        }


        // Constructor: Number value
        public Cell(Integer ci, Integer ri, Decimal v){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'n';
        }


        // Constructor: Boolean value
        public Cell(Integer ci, Integer ri, Boolean v){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'b';
        }


        // Constructor: Formula value
        public Cell(Integer ci, Integer ri, Object v, String f){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'str';
            this.f  = f;
        }


        /**
         * CONSTRUCTORS WITH STYLES
         */
        // Constructor: Text value
        public Cell(Boolean useSharedStrings, Integer ci, Integer ri, String v, Integer s){
            this.v  = v;
            this.ci = ci;
            this.ri = ri;
            this.t  = useSharedStrings ? 's' : 'inlineStr';
            this.s  = s;
        }



        // Constructor: Number value
        public Cell(Integer ci, Integer ri, Integer v, Integer s){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'n';
            this.s  = s;
        }


        // Constructor: Number value
        public Cell(Integer ci, Integer ri, Decimal v, Integer s){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'n';
            this.s  = s;
        }


        // Constructor: Boolean value
        public Cell(Integer ci, Integer ri, Boolean v, Integer s){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'b';
            this.s  = s;
        }


        // Constructor: Formula value
        public Cell(Integer ci, Integer ri, Object v, String f, Integer s){
            this.v  = v.toString();
            this.ci = ci;
            this.ri = ri;
            this.t  = 'str';
            this.f  = f;
            this.s  = s;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){

            // Empty cells don't need to be part the worksheet so can be ignored
            if(this.v == null){return;}

            // Write the cell, note that the R element does not use the getCellName() method to save speed
            x.writeStartElement(null, 'c', null);
            x.writeAttribute(null, null, 'r', BuildUtil.columnNames[this.ci] + BuildUtil.rowNames[this.ri]);
            x.writeAttribute(null, null, 't', this.t);

            if(this.s != null){x.writeAttribute(null, null, 's', this.s.toString());}

            // Write cell value based on the type
            switch on this.t {

                // Shared String
                when 's' {
                    x.writeStartElement(null, 'v', null);
                    x.writeCharacters(v);
                    x.writeEndElement();
                }

                // When a number write the number value
                // Number values don't have to be escaped
                when 'n','b' {
                    x.writeStartElement(null, 'v', null);
                    x.writeCharacters(this.v.toString());
                    x.writeEndElement();
                }

                // Formula
                when 'str' {
                    x.writeStartElement(null, 'f', null);
                    x.writeCharacters(this.f);
                    x.writeEndElement();

                    x.writeStartElement(null, 'v', null);
                    x.writeCharacters(''+this.v);
                    x.writeEndElement();
                }

                // By default write inline strings
                when else {
                    x.writeStartElement(null, 'is', null);
                    x.writeStartElement(null, 't', null);
                    x.writeCharacters(this.v);
                    x.writeEndElement();
                    x.writeEndElement();
                }
            }

            // Close the cell
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the autoFilter Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > autoFilter
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_autoFilter_topic_ID0EIDM4.html#topic_ID0EIDM4
     */
    public with sharing class AutoFilter implements IXmlElement{

        Integer startCi;
        Integer startRi;
        Integer endCi;
        Integer endRi;

        /**
         * @description Constructor for the AutoFilter class
         * @param startCi The column index of the first cell to be merged
         * @param startRi The row index of the first cell to be merged
         * @param endCi   The column index of the last cell to be merged
         * @param endRi   The row index of the last cell to be merged
         */
        public AutoFilter(Integer startCi, Integer startRi, Integer endCi, Integer endRi){
            this.startCi = startCi;
            this.startRi = startRi;
            this.endCi   = endCi;
            this.endRi   = endRi;
        }

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'autoFilter', null);
            x.writeAttribute(null, null, 'ref', BuildUtil.getCellRange(startCi, startRi, endCi, endRi));
        }
    }


    /**
     * @description Data structure representing the mergeCells Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > mergeCells
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_mergeCells_topic_ID0EFE44.html#topic_ID0EFE44
     */
    public with sharing class MergeCells implements IXmlElement{

        // Any merge cells go in here
        public MergeCell[] mergeCells = new MergeCell[]{};


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(x, null, 'mergeCells', this.mergeCells);
        }
    }


    /**
     * @description Data structure representing the mergeCell Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > mergeCells > mergeCell
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_mergeCell_topic_ID0ET634.html#topic_ID0ET634
     */
    public with sharing class MergeCell implements IXmlElement{

        private Integer startCi;
        private Integer startRi;
        private Integer endCi;
        private Integer endRi;

        /**
         * @description Constructor for the MergeCell class
         * @param startCi The column index of the first cell to be merged
         * @param startRi The row index of the first cell to be merged
         * @param endCi   The column index of the last cell to be merged
         * @param endRi   The row index of the last cell to be merged
         */
        public MergeCell(Integer startCi, Integer startRi, Integer endCi, Integer endRi){
            this.startCi = startCi;
            this.startRi = startRi;
            this.endCi   = endCi;
            this.endRi   = endRi;
        }

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(   null, 'mergeCell', null);
            x.writeAttribute(null, null, 'ref', BuildUtil.getCellRange(startCi, startRi, endCi, endRi));
        }
    }


    /**
     * @description Data structure representing the hyperlinks Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > hyperlinks
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_hyperlinks_topic_ID0EX114.html
     */
    public with sharing class Hyperlinks implements IXmlElement{

        // Any hyperlinked cells go in here
        public Hyperlink[] hyperlinks = new Hyperlink[]{};

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(
                x, null, 'hyperlinks', this.hyperlinks
            );
        }
    }


    /**
     * @description Data structure representing the hyperlink Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > hyperlinks > hyperlink
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_hyperlink_topic_ID0EFQ14.html#topic_ID0EFQ14
     */
    public with sharing class Hyperlink implements IXmlElement{

        // Attributes
        private Integer ci;
        private Integer ri;
        private String location;
        private String display;

        /**
         * @description Constructor for the Hyperlink class
         * @param ci       The column index of the cell that contains the hyperlink
         * @param ri       The row index of the cell that contains the hyperlink
         * @param location The location of the hyperlink
         * @param display  The display text of the hyperlink
         */
        public Hyperlink(Integer ci, Integer ri, String location, String display){
            this.ci       = ci;
            this.ri       = ri;
            this.location = location;
            this.display  = display;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(   null, 'hyperlink',null);
            x.writeAttribute(null, null, 'ref',      BuildUtil.getCellName(ci, ri) );
            x.writeAttribute(null, null, 'location', this.location);
            x.writeAttribute(null, null, 'display',  this.display);
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the pageMargins Xml Element
     * @file        sheet{0}.xml
     * @path        worksheet > pageMargins
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_pageMargins_topic_ID0ERN54.html#topic_ID0ERN54
     */
    public with sharing class PageMargins implements IXmlElement{

        // Attributes
        public Decimal left   = 0.75;
        public Decimal right  = 0.75;
        public Decimal top    = 0.75;
        public Decimal bottom = 0.75;
        public Decimal header = 0.25;
        public Decimal footer = 0.25;

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(   null, 'pageMargins', null);
            x.writeAttribute(null, null, 'left',   this.left  .setScale(2).toString());
            x.writeAttribute(null, null, 'right',  this.right .setScale(2).toString());
            x.writeAttribute(null, null, 'top',    this.top   .setScale(2).toString());
            x.writeAttribute(null, null, 'bottom', this.bottom.setScale(2).toString());
            x.writeAttribute(null, null, 'header', this.header.setScale(2).toString());
            x.writeAttribute(null, null, 'footer', this.footer.setScale(2).toString());

        }
    }


    /** **************************************************************************************************** **
     **                                      CONTENT TYPE XML ELEMENTS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the Types Xml Element
     * @file        [Content_Types].xml
     * @path        Types (note the capital T)
     * @docs        https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Types_topic_ID0EQYAI.html
     */
    public with sharing class Types implements IXmlElement{

        // List to hold the overrides
        public TypeOverride[] overrides = new XmlElement.TypeOverride[]{
            new XmlElement.TypeOverride(Constant.CT_PATH_RELS,          Constant.CT_RELATIONSHIPS  ),
            new XmlElement.TypeOverride(Constant.CT_PATH_WORKBOOK_RELS, Constant.CT_RELATIONSHIPS  ),
            new XmlElement.TypeOverride(Constant.CT_PATH_WORKBOOK,      Constant.CT_SHEET          ),
            new XmlElement.TypeOverride(Constant.CT_PATH_STYLES,        Constant.CT_STYLES         ),
            new XmlElement.TypeOverride(Constant.CT_PATH_SHRD_STRS,     Constant.CT_SHRD_STRS      ),
            new XmlElement.TypeOverride(Constant.CT_PATH_APP,           Constant.CT_EXT_PROPERTIES ),
            new XmlElement.TypeOverride(Constant.CT_PATH_CORE,          Constant.CT_CORE_PROPERTIES)
        };

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildrenAndDefaultNamespace(
                x, null, 'Types', this.overrides, Constant.NS_CONTENT_TYPES
            );
        }
    }


    /**
     * @description Data structure representing the Types Xml Element
     * @file        [Content_Types].xml
     * @path        Types > Override (note the capital T & capital O)
     * @docs        https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Override_topic_ID0EXKBI.html
     */
    public class TypeOverride implements IXmlElement{

        // Attributes
        private String partName;
        private String contentType;

        /**
         * @description default constructor
         * @param partName    The part name
         * @param contentType The content type
         */
        public TypeOverride(String partName,String contentType){
            this.partName    = partName;
            this.contentType = contentType;
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'Override', null);
            x.writeAttribute(null, null, 'PartName',    this.partName   );
            x.writeAttribute(null, null, 'ContentType', this.contentType);
        }
    }


    /** **************************************************************************************************** **
     **                                       RELATIONSHIP XML ELEMENTS                                      **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing the Relationships Xml Element
     * @file        .rels, workbook.xml.rels
     * @path        Relationships (note the capital R)
     * @docs        https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Relationships_topic_ID0EUBBG.html
     */
    public with sharing class Relationships implements IXmlElement{

        // List of relationships
        public Relationship[] relationships = new Relationship[]{};

        /**
         * @description The workbook relationships constructor. No default relationships are created
         *              The relationships for workbooks are created when a worksheet is added
         * @param isWorkbook Indicator if it is a workbook relationship
         */
        public Relationships(Boolean isWorkbook){
            if(isWorkbook){

                // Add the relationship to the styles.xml
                this.relationships.add(new XmlElement.Relationship(
                    'rId1',
                    Constant.NS_REL_STYLES,
                    Constant.REL_PATH_STYLES
                ));

                // Add the relationship to the sharedStrings.xml
                this.relationships.add(new XmlElement.Relationship(
                    'rId2',
                    Constant.NS_REL_SHRD_STRS,
                    Constant.REL_PATH_SHRD_STRS
                ));

            }else{

                // Add the required default relationships
                this.relationships.add(
                    new XmlElement.Relationship(
                       'rId1',
                        Constant.NS_REL_OFFICE_DOC,
                        Constant.REL_PATH_WORKBOOK
                    )
                );

                // Add core props relationship
                this.relationships.add(
                    new XmlElement.Relationship(
                        'rId2',
                        Constant.NS_REL_CORE_PROP,
                        Constant.REL_PATH_CORE
                    )
                );

                // Add doc props relationship
                this.relationships.add(
                    new XmlElement.Relationship(
                        'rId3',
                        Constant.NS_REL_EXT_PROP,
                        Constant.REL_PATH_APP
                    )
                );
            }
        }


        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildrenAndDefaultNamespace(
                x, null, 'Relationships', this.relationships, Constant.NS_RELATIONSHIPS
            );
        }
    }


    /**
     * @description Data structure representing the Relationship Xml Element
     * @file        .rels, workbook.xml.rels
     * @path        Relationships > Relationship (note the capital R)
     * @docs        https://c-rex.net/samples/ooxml/e1/Part2/OOXML_P2_Open_Packaging_Conventions_Relationship_topic_ID0EKFBG.html
     */
    public with sharing class Relationship implements IXmlElement{

        // Attributes (Attribute names do not match due to reserved key words)
        private String rId;
        private String rType;
        private String rTarget;

        /**
         * @description Constructor for the Relationship class
         * @param rId     The Id of the relationship
         * @param rType   The type of the relationship
         * @param rTarget The * of the relationship
         */
        public Relationship(String rId, String rType, String rTarget){
            this.rId    = rId;
            this.rType  = rType;
            this.rTarget= rTarget;
        }

        /**
         * @description Method to write the class to XML
         * @param x     The XmlStreamWriter class instance to write to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'Relationship', null);
            x.writeAttribute(null, null, 'Id',    this.rId);
            x.writeAttribute(null, null, 'Type',   this.rType);
            x.writeAttribute(null, null, 'Target', this.rTarget);
        }
    }
}