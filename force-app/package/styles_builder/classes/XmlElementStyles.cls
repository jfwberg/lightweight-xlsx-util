/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds all the classes that represent XML elements
 * @false-positive OneDeclarationPerLine    Only occurs in for loops for optimization purposes
 * @false-positive CognitiveComplexity      Way over the threshold, but this is because of the nature
 *                                          of lots of small XML writing statements with null cells.
 *                                          Unless you split into many different files, the complexity
 *                                          will be very high, but it's not difficult to read.
 * @false-positive CyclomaticComplexity     Caused by the many if statements and null checks for many
 *                                          individual XML element checks and validations
 * @false-positive StdCyclomaticComplexity  Just 1 over the threshold, I can live with that
 * @false-positive NcssMethodCount          Just 4 over the threshold, I can live with that
 * @false-positive ExcessiveParameterList   I need to find a nicer way for the massive amount of parameters.
 *                                          Unfortunately there are many of them and this is the easiest for now.
 */
@SuppressWarnings('PMD.OneDeclarationPerLine, PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity, PMD.NcssMethodCount, PMD.ExcessiveParameterList')
public with sharing class XmlElementStyles {

    /**
     * @description Data structure representing the styleSheet Xml Element
     * @file        styles.xml
     * @path        styleSheet
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_styleSheet_topic_ID0EOYN6.html
     */
    public class StyleSheet implements IXmlElement{

        // child elements
        public NumFmts      numFmts      = new NumFmts();
        public Fonts        fonts        = new Fonts();
        public Fills        fills        = new Fills();
        public Borders      borders      = new Borders();
        public CellXfs      cellXfs      = new CellXfs();
        public Colors       colors       = new Colors();

        // This is not an official element in the XML, but this will keep the
        // Coding implementation equal for all style elements
        public Alignments  alignments   = new Alignments();

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'styleSheet', null);
            x.writeDefaultNamespace(Constant.NS_SPREADSHEET_ML);
            if(!this.numFmts.numFmts.isEmpty()          ){ this.numFmts.writeXml(x);}
            if(!this.fonts.fonts.isEmpty()              ){ this.fonts.writeXml(x);}
            if(!this.fills.fills.isEmpty()              ){ this.fills.writeXml(x);}
            if(!this.borders.borders.isEmpty()          ){ this.borders.writeXml(x);}
            if(!this.cellXfs.cellXfs.isEmpty()          ){ this.cellXfs.writeXml(x);}
            if(!this.colors.mruColors.colors.isEmpty()  ){ this.colors.writeXml(x);}
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the borders Xml Element
     * @file        styles.xml
     * @path        styleSheet > borders
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_borders_topic_ID0EKI45.html#topic_ID0EKI45
     */
    public class Borders implements IXmlElement{

        // Child elements
        public Border[] borders = new Border[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'borders', null);
            if(!this.borders.isEmpty()){x.writeAttribute(null, null, 'count', this.borders.size().toString());}
            for(Integer i=0,max=this.borders.size(); i<max;i++){
                this.borders[i].writeXml(x);
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the Border Xml Element
     * @file        styles.xml
     * @path        styleSheet > border > Border
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_border_topic_ID0EVV35.html
     */
    public class Border implements IXmlElement{

        // Attributes
        public Boolean diagonalUp;
        public Boolean diagonalDown;
        public Boolean outline;

        // Child elements
        public BorderAttribute left     = new BorderAttribute('left');
        public BorderAttribute right    = new BorderAttribute('right');
        public BorderAttribute top      = new BorderAttribute('top');
        public BorderAttribute bottom   = new BorderAttribute('bottom');
        public BorderAttribute diagonal = new BorderAttribute('diagonal');

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'border', null);
            this.left.writeXml(x);
            this.right.writeXml(x);
            this.top.writeXml(x);
            this.bottom.writeXml(x);
            this.diagonal.writeXml(x);
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the Border Xml Element attributes
     * @file        styles.xml
     * @path        styleSheet > border > Border
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_border_topic_ID0EVV35.html
     */
    public class BorderAttribute implements IXmlElement{

        // private variables
        private String attribute;

        // attributes
        public String style;

        // Child elements
        public Color color;

        /**
         * @description Default constructor as the attribute type is mandatory
         * @param attribute The border attribute top, bottom, left, right etc.
         */
        public BorderAttribute(String attribute){
            this.attribute = attribute;
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, this.attribute, null);
            if(this.style != null){x.writeAttribute(null, null, 'style',  this.style);}
            if(this.color != null){color.writeXml(x);}
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the fills Xml Element
     * @file        styles.xml
     * @path        styleSheet > fills
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_fills_topic_ID0EVNC6.html
     */
    public class Fills implements IXmlElement{

        // Child elements
        public Fill[] fills = new Fill[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'fills', null);
            if(!this.fills.isEmpty()){x.writeAttribute(null, null, 'count', this.fills.size().toString());}
            for(Integer i=0,max=this.fills.size(); i<max;i++){
                this.fills[i].writeXml(x);
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the Fill Xml Element
     * @file        styles.xml
     * @path        styleSheet > fills > Fill
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_fill_topic_ID0E2FC6.html
     */
    public class Fill implements IXmlElement{

        // The fill pattern
        public PatternFill  patternFill;

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'fill', null);
            if(this.patternFill  != null){ patternFill.writeXml(x); }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the patternFill Xml Element
     * @file        styles.xml
     * @path        styleSheet > fills > Fill > patternFill
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_patternFill_topic_ID0E6KM6.html#topic_ID0E6KM6
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_ST_PatternType_topic_ID0EBYQFB.html#topic_ID0EBYQFB
     */
    public class PatternFill implements IXmlElement{

        // The fill style is solid. When solid is specified, the foreground color (<fgColor>) is
        // the only color rendered, even when a background color (<bgColor>) is also specified.
        public String patternType;

        // Child elements
        public FgColor fgColor;
        public BgColor bgColor;


        /**
         * @description Default constructor
         * @param patternType   The pattern type, none, solid, lightGray, mediumGray, darkGray erc.
         * @param fgColor       Foreground color
         * @param bgColor       Background color
         */
        public PatternFill(String patternType, String fgColor, String bgColor){
            this.patternType = patternType;
            this.fgColor     = fgColor != null  ? new FgColor(fgColor) : null;
            this.bgColor     = bgColor != null  ? new BgColor(bgColor) : (fgColor != null) ? new BgColor(null) : null;

        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'patternFill', null);
            x.writeAttribute(null, null, 'patternType', this.patternType);
            if(this.fgColor != null){this.fgColor.writeXml(x);}
            if(this.bgColor != null){this.bgColor.writeXml(x);}
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the patternFill Xml Element
     * @file        styles.xml
     * @path        styleSheet > fills > Fill > patternFill > FgColor
     * @docs
     */
    public with sharing class FgColor implements IXmlElement{

        // Attributes
        private String rgb;

        /**
         * @description Default constructor, removes a # in front of a rgb code
         * @param rgb The RGB hex code without hash
         */
        public FgColor(String rgb){
            this.rgb = rgb?.removeStart('#');
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'fgColor', null);
            if(this.rgb != null){x.writeAttribute(null, null, 'rgb', this.rgb );}
        }

    }


    /**
     * @description Data structure representing the patternFill Xml Element
     * @file        styles.xml
     * @path        styleSheet > fills > Fill > patternFill > BgColor
     * @docs
     */
    public with sharing class BgColor implements IXmlElement{

        // Attributes
        private String rgb;

        /**
         * @description Default constructor, removes a # in front of a rgb code
         * @param rgb The RGB hex code without hash
         */
        public BgColor(String rgb){
            this.rgb = rgb?.removeStart('#');
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'bgColor', null);
            if(this.rgb != null){x.writeAttribute(null, null, 'rgb', this.rgb );}
        }

    }


    /**
     * @description Data structure representing the fonts Xml Element
     * @file        styles.xml
     * @path        styleSheet > fonts
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_fonts_topic_ID0E2ND6.html
     */
    public class Fonts implements IXmlElement{

        // Child attributes
        public Font[] fonts = new Font[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'fonts', null);
            if(!this.fonts.isEmpty()){x.writeAttribute(null, null, 'count', this.fonts.size().toString());}
            for(Integer i=0,max=this.fonts.size(); i<max;i++){
                this.fonts[i].writeXml(x);
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the font Xml Element
     * @file        styles.xml
     * @path        styleSheet > fonts > font
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_font_topic_ID0EAXC6.html
     */
    public class Font implements IXmlElement{

        // Child elements
        public Color color;
        public Boolean b;     // Bold
        public Boolean i;     // Italic
        public Boolean u;     // Underline
        public FontAttribute sz;    // Size
        public FontAttribute name;
        public FontAttribute family;
        public FontAttribute scheme;

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){

            x.writeStartElement(null, 'font', null);

            if(this.b == true){new FontAttribute('b',null).writeXml(x);}
            if(this.i == true){new FontAttribute('i',null).writeXml(x);}
            if(this.u == true){new FontAttribute('u',null).writeXml(x);}


            if(this.sz     != null){sz.writeXml(x);}
            if(this.color  != null){color.writeXml(x);}
            if(this.name   != null){name.writeXml(x);}
            if(this.family != null){family.writeXml(x);}
            if(this.scheme != null){scheme.writeXml(x);}
            x.writeEndElement();
        }
    }


    /**
     * @description Custom data structure to accommodate multiple attributes efficiently
     * @file        styles.xml
     * @path        na
     * @docs        na
     */
    public class FontAttribute implements IXmlElement{

        // Child attributes
        public String attributeName;
        public String val;

        /**
         * @description Default constructor
         * @param attributeName The font attribute name
         * @param val           The attribute value
         */
        public FontAttribute(String attributeName, Object val){
            this.attributeName = attributeName;
            this.val           = (val ?? '').toString(); // [DEBUG]
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, this.attributeName, null);
            if(String.isNotBlank(this.val)){x.writeAttribute(null, null, 'val', this.val);}
        }
    }


    /**
     * @description Class representing the NumFmts XML Element
     * @file        styles.xml
     * @path        styleSheet > numFmts
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_numFmts_topic_ID0E6KK6.html#topic_ID0E6KK6
     */
    public class NumFmts implements IXmlElement{

        // Child elements
        public NumFmt[] numFmts = new NumFmt[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'numFmts', null);
            if(!this.numFmts.isEmpty()){x.writeAttribute(null, null, 'count', this.numFmts.size().toString());}
            for(Integer i=0,max=this.numFmts.size(); i<max;i++){
                this.numFmts[i].writeXml(x);
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Holding element for the NumFmt Id
     * @file        styles.xml
     * @path        styleSheet > numFmts > NumFmt
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_numFmt_topic_ID0EHDH6.html
     */
    public class NumFmt implements IXmlElement{

        // Attributes
        private Integer numFmtId;
        private String formatCode;

        /**
         * @description Default constructor as the attribute type is mandatory
         * @param numFmtId   The number format id
         * @param formatCode The formatCode
         */
        public NumFmt(Integer numFmtId, String formatCode){
            this.numFmtId   = numFmtId;
            this.formatCode = formatCode;
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'numFmt', null);
            if(this.numFmtId   != null){x.writeAttribute(null, null, 'numFmtId',   this.numFmtId.toString()  );}
            if(this.formatCode != null){x.writeAttribute(null, null, 'formatCode', this.formatCode                );}
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the cellXfs Xml Element
     * @file        styles.xml
     * @path        styleSheet > CellXfs
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_cellXfs_topic_ID0EMAA6.html
     */
    public class CellXfs implements IXmlElement{

        // Child elements
        public Xf[] cellXfs = new Xf[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'cellXfs', null);
            if(!this.cellXfs.isEmpty()){x.writeAttribute(null, null, 'count', this.cellXfs.size().toString());}
            for(Integer i=0,max=this.cellXfs.size(); i<max;i++){
                this.cellXfs[i].writeXml(x);
            }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the Xf Xml Element
     * @file        styles.xml
     * @path        styleSheet > CellXfs > xf
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_xf_topic_ID0E13S6.html#topic_ID0E13S6
     */
    public class Xf implements IXmlElement{

        // Attributes
        public Integer numFmtId;
        public Integer fontId;
        public Integer fillId;
        public Integer borderId;
        public Integer xfId;
        public Boolean applyAlignment    = false;
        public Boolean applyBorder       = false;
        public Boolean applyFill         = false;
        public Boolean applyFont         = false;
        public Boolean applyNumberFormat = false;

        // Child element
        public Alignment alignment;

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeStartElement(null, 'xf', null);

            if(this.numFmtId    != null){ x.writeAttribute(null, null, 'numFmtId',          this.numFmtId.toString() ) ;}
            if(this.fontId      != null){ x.writeAttribute(null, null, 'fontId',            this.fontId.toString()   ) ;}
            if(this.fillId      != null){ x.writeAttribute(null, null, 'fillId',            this.fillId.toString()   ) ;}
            if(this.borderId    != null){ x.writeAttribute(null, null, 'borderId',          this.borderId.toString() ) ;}
            if(this.xfId        != null){ x.writeAttribute(null, null, 'xfId',              this.xfId.toString()     ) ;}

            if(this.applyAlignment     ){ x.writeAttribute(null, null, 'applyAlignment',    '1'                       );}
            if(this.applyBorder        ){ x.writeAttribute(null, null, 'applyBorder',       '1'                       );}
            if(this.applyFill          ){ x.writeAttribute(null, null, 'applyFill',         '1'                       );}
            if(this.applyFont          ){ x.writeAttribute(null, null, 'applyFont',         '1'                       );}
            if(this.applyNumberFormat  ){ x.writeAttribute(null, null, 'applyNumberFormat', '1'                       );}

            if(this.alignment !=null   ){ alignment.writeXml(x);                                                        }
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the MruColors Xml Element
     * @file        styles.xml
     * @path        mruColors
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_mruColors_topic_ID0ETZG6.html#topic_ID0ETZG6
     */
    public with sharing class MruColors implements IXmlElement{

        // Child elements
        public Color[] colors = new Color[]{};

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            BuildUtil.writeSingleXmlElementWithChildren(x, null, 'mruColors', this.colors);
        }
    }


    /**
     * @description Data structure representing the MruColors Xml Element
     * @file        styles.xml
     * @path        mruColors > colors
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_mruColors_topic_ID0ETZG6.html#topic_ID0ETZG6
     */
    public with sharing class Colors implements IXmlElement{

        // Child elements
        public MruColors mruColors = new MruColors();

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){

            // Start colors
            x.writeStartElement(null, 'colors', null);
            this.mruColors.writeXml(x);
            x.writeEndElement();
        }
    }


    /**
     * @description Data structure representing the MruColors Xml Element
     * @file        styles.xml
     * @path        mruColors > colors > Color
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_color_topic_ID0EL5Q4.html#topic_ID0EL5Q4
     */
    public with sharing class Color implements IXmlElement{

        // Standard Alpha Red Green Blue color value (ARGB) 4 hex characters... Hex binary format
        private String rgb;

        /**
         * @description Main Constructor
         * @param rgb   The RGB color code (hex)
         */
        public Color(String rgb){
            this.rgb = rgb;
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'color', null);
            if(this.rgb   != null ){ x.writeAttribute(null, null, 'rgb',  this.rgb );}
        }
    }


    /**
     * @description Data structure representing the borders Xml Element
     *              Note that this element does not exist is is here to
     *              keep the coding style equal.
     * @note        This method does not implement any interface
     * @file        n/a
     * @path        n/a
     * @docs        n/a
     */
    public class Alignments{

        // List of alignments to assign to the Xf elements
        public Alignment[] alignments = new Alignment[]{};


    }


    /**
     * @description Data structure representing the alignment Xml Element
     * @file        styles.xml
     * @path        styleSheet > cellStyleXfs > xf > alignment
     * @docs        https://c-rex.net/samples/ooxml/e1/Part4/OOXML_P4_DOCX_alignment_topic_ID0EQT25.html
     */
    public class Alignment implements IXmlElement{

        // general, justify, left, right, center, fill, centerContinuous
        private String horizontal;

        // top, bottom, center, distributed, justify
        private String vertical;

        // 0 tot 180
        private Integer textRotation;

        // wrap the text in the cell
        private Boolean wrapText;

        /**
         * @description Default constructor
         * @param horizontal    The horizontal alignment of the text
         * @param vertical      The vertical alignment of the text
         * @param textRotation  The rotation of the text
         * @param wrapText      Indicates whether the text should wrap
         */
        public Alignment(String horizontal, String vertical, Integer textRotation, Boolean wrapText){
            this.horizontal = horizontal;
            this.vertical = vertical;
            this.textRotation = textRotation;
            this.wrapText = wrapText;
        }

        /**
         * @description Method to write this element values to an XML equivalent
         * @param x The XmlStreamWriter to add to
         */
        public void writeXml(XmlStreamWriter x){
            x.writeEmptyElement(null, 'alignment', null);
            if(this.horizontal   != null){x.writeAttribute(null, null, 'horizontal',    horizontal              );}
            if(this.vertical     != null){x.writeAttribute(null, null, 'vertical',      vertical                );}
            if(this.textRotation != null){x.writeAttribute(null, null, 'textRotation',  textRotation.toString() );}
            if(this.wrapText     == true){x.writeAttribute(null, null, 'wrapText',      '1'                     );}
        }
    }
}