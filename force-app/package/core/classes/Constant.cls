/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class containing all the static values that are used
 *                 to generate the various XML Files in the package
 * @warning        !! Do not touch !!: Changing a single capital in this section might break you file !!
 */
public with sharing class Constant {

    /** **************************************************************************************************** **
     **                                            SAFE TO UPDATE                                            **
     ** **************************************************************************************************** **/
    // Static application info (Safe to update)
    public static final String  APP_NAME                    = 'Lightweight - XLSX Builder';
    public static final Integer REVISION                    = 0;
    public static final String  CREATOR                     = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
    public static final String  COMPANY_NAME                = UserInfo.getOrganizationName();

    // Switch between inline strings in cells and the shared strings
    // Setting this to true can be beneficial for sheets that have lots of shared values
    public static final Boolean DEF_SHARED_STRINGS          = true;

    // Include the default styles, handy for testing or company default
    public static final Boolean DEF_INCLUDE_STYLES          = false;
    
    // Static resource file name for the default instructions
    public static final String  LLM_DEF_INSTRUCTION_SR      = 'llm_default_instructions';

    // (Error) Messages
    public static final String  MSG_INVALID_WS_NAME         = 'Worksheet name cannot be blank or exceed 31 characters in length';
    public static final String  MSG_DUPLICATE_WORKSHEET     = 'A worksheet with the name "{0}" already exists in the builder.';
    public static final String  MSG_INVALID_CELL_NAME       = 'Invalid cell name: "{0}"';
    public static final String  MSG_INVALID_ZIP_ENTRY       = 'The file name "{0}" does not exist in the zip entries map.';
    public static final String  MSG_NO_DIMENSION_ATTR       = 'The worksheet does not contain the "dimension" attribute. To use the "toArray()" methods, this attribute is required. Please use the "toMap()" methods. This often happens with sheets created in Google Sheets. A solution is on the roadmap.';
    public static final String  MSG_STATIC_RESOURCE_ERROR   = 'No static resource with the name "{0}" found in the metadata';
    public static final String  MSG_LLM_TEXT_UNKNOWN_ERROR  = 'An unexpected error occurred whilst processing the ContentDocument. Exception Message: "{0}"';
    public static final String  MSG_FORCED_EXCEPTION        = 'This is a forced exception error message used for code coverage';
    public static final String  MSG_XLSX_EXTENSION_EXCEPTION= 'The content document extension is invalid. Only the "xlsx" extension is supported';


    /** **************************************************************************************************** **
     **                                          !! DO NOT TOUCH !!                                          **
     ** **************************************************************************************************** **/
    // Current timestamp that is used throughout the sheet for consistency
    public static final DateTime NOW                = Datetime.now();

    // Formatted output of the timestamp
    public static final String   TIMESTAMP_FORMAT   = 'yyyyMMdd_HHmmss';
    public static final String   ISO_8601_FORMAT    = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

    // Utility related values
    public static final String   DEF_SHEET_TITLE    = 'Sheet{0}';
    public static final String   INVALID_SHEET_TITLE= 'invalid_sheet_name_{0}';
    public static final String   DEF_FOLDER_ID      = UserInfo.getUserId();
    public static final String   DEF_FILE_NAME      = CommonUtil.getTimestampString() + '_unknown_file_name.xlsx';
    public static final String   DEF_TITLE          = 'Unknown Title (' + CommonUtil.getTimestampString() + ')';
    public static final String   FULL_FILE_EXTENSION= '.xlsx';

    // The worksheet relationship Id (RID) offset (Because 2 relationships exist by default)
    public static final Integer  WS_RID_OFFSET      = 2;

    // Some popular libraries set the default dimension value to A1
    // this creates some issues when the sheet is actually larger
    // When the default value is selected, ignore the dimension tag
    public static final String   DEF_SNGL_DIMENSION = 'a1';

    // Regex to sanitize worksheet names
    public static final String   WS_NAME_REGEX      = '[\\\\\\/?*:\\[\\]]';

    // Regex to get the name of the cell.
    public static final String   CELL_NAME_REGEX    = '^([a-zA-Z]+)';

    // Patern generated from the cell name so the pattern compilation only has to be executed once
    public static final Pattern  CELL_NAME_PATTERN  = Pattern.compile(CELL_NAME_REGEX);
    
    // Regex to get a cell range
    public static final String   CELL_RANGE_REGEX    = '^([A-Za-z]+)(\\d+)(?::([A-Za-z]+)(\\d+))?$';

    // Patern generated from the cell range so the pattern compilation only has to be executed once
    public static final Pattern  CELL_RANGE_PATTERN  = Pattern.compile(CELL_RANGE_REGEX);

    // Character Array to calculate column names
    // Added a spacer ^ to prevent a calculation 
    public static final String[] CHARS              = '^ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    // Number array to reverse calculate the numbers column names
    public static final Map<String,Integer> NUMS    = new Map<String,Integer>{
                                                            'A'=> 1,'B'=> 2,'C'=> 3,'D'=> 4,'E'=> 5,'F'=> 6,'G'=> 7,'H'=> 8,'I'=> 9,'J'=>10,
                                                            'K'=>11,'L'=>12,'M'=>13,'N'=>14,'O'=>15,'P'=>16,'Q'=>17,'R'=>18,'S'=>19,'T'=>20,
                                                            'U'=>21,'V'=>22,'W'=>23,'X'=>24,'Y'=>25,'Z'=>26
    };

    // XML File settings
    public static final String ENCODING             = 'UTF-8';
    public static final String VERSION              = '1.0';

    // Folder names that specify where the files live in the zip archive
    public static final String FOLDER_BLANK         = '';
    public static final String FOLDER_DOC_PROPS     = 'docProps/';
    public static final String FOLDER_XL            = 'xl/';
    public static final String FOLDER_XL_WORKSHEET  = 'xl/worksheets/';
    public static final String FOLDER_WORKSHEET     = 'worksheets/';
    public static final String FOLDER_RELS          = '_rels/';
    public static final String FOLDER_XL_RELS       = 'xl/_rels/';

    // File names of the files inside the XMl Package
    public static final String FILE_SHRD_STRS       = 'sharedStrings.xml';
    public static final String FILE_STYLES          = 'styles.xml';
    public static final String FILE_CORE            = 'core.xml';
    public static final String FILE_APP             = 'app.xml';
    public static final String FILE_WORKBOOK        = 'workbook.xml';
    public static final String FILE_SHEET           = 'sheet{0}.xml';
    public static final String FILE_CONTENT_TYPES   = '[Content_Types].xml';
    public static final String FILE_RELS            = '.rels';
    public static final String FILE_WORKBOOK_RELS   = 'workbook.xml.rels';
    
    // Regex pattern for the worksheet path inside the zip archive
    public static final String WORKSHEET_PATH_REGEX = '^xl/worksheets/sheet\\d+\\.xml$';

    // Relationship paths (!! Not the same as the folder path in the package !!)
    public static final String REL_PATH_SHRD_STRS   = FOLDER_BLANK     + FILE_SHRD_STRS;
    public static final String REL_PATH_STYLES      = FOLDER_BLANK     + FILE_STYLES;
    public static final String REL_PATH_CORE        = FOLDER_DOC_PROPS + FILE_CORE;
    public static final String REL_PATH_APP         = FOLDER_DOC_PROPS + FILE_APP;
    public static final String REL_PATH_WORKBOOK    = FOLDER_XL        + FILE_WORKBOOK;
    public static final String REL_PATH_SHEET       = FOLDER_WORKSHEET + FILE_SHEET;

    // File Paths for the zip archive
    public static final String ZP_PATH_SHRD_STRS    = FOLDER_XL           + FILE_SHRD_STRS;
    public static final String ZP_PATH_STYLES       = FOLDER_XL           + FILE_STYLES;
    public static final String ZP_PATH_CORE         = FOLDER_DOC_PROPS    + FILE_CORE;
    public static final String ZP_PATH_APP          = FOLDER_DOC_PROPS    + FILE_APP;
    public static final String ZP_PATH_WORKBOOK     = FOLDER_XL           + FILE_WORKBOOK;
    public static final String ZP_PATH_SHEET        = FOLDER_XL_WORKSHEET + FILE_SHEET;
    public static final String ZP_PATH_CONTENT_TYPES= FOLDER_BLANK        + FILE_CONTENT_TYPES;
    public static final String ZP_PATH_RELS         = FOLDER_RELS         + FILE_RELS;
    public static final String ZP_PATH_WORKBOOK_RELS= FOLDER_XL_RELS      + FILE_WORKBOOK_RELS;

    // Content Type Override Paths
    public static final String CT_PATH_SHRD_STRS    = '/' + FOLDER_XL           + FILE_SHRD_STRS;
    public static final String CT_PATH_STYLES       = '/' + FOLDER_XL           + FILE_STYLES;
    public static final String CT_PATH_CORE         = '/' + FOLDER_DOC_PROPS    + FILE_CORE;
    public static final String CT_PATH_APP          = '/' + FOLDER_DOC_PROPS    + FILE_APP;
    public static final String CT_PATH_WORKBOOK     = '/' + FOLDER_XL           + FILE_WORKBOOK;
    public static final String CT_PATH_SHEET        = '/' + FOLDER_XL_WORKSHEET + FILE_SHEET;
    public static final String CT_PATH_RELS         = '/' + FOLDER_RELS         + FILE_RELS;
    public static final String CT_PATH_WORKBOOK_RELS= '/' + FOLDER_XL_RELS      + FILE_WORKBOOK_RELS;

    // File Content Types
    public static final String CT_SHRD_STRS         = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml';
    public static final String CT_STYLES            = 'application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml';
    public static final String CT_CORE_PROPERTIES   = 'application/vnd.openxmlformats-package.core-properties+xml';
    public static final String CT_EXT_PROPERTIES    = 'application/vnd.openxmlformats-officedocument.extended-properties+xml';
    public static final String CT_SHEET             = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml';
    public static final String CT_WORKSHEET         = 'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml';
    public static final String CT_RELATIONSHIPS     = 'application/vnd.openxmlformats-package.relationships+xml';

    // Top level XML Namespaces
    public static final String NS_XSI               = 'http://www.w3.org/2001/XMLSchema-instance';
    public static final String NS_DC_ELMTS          = 'http://purl.org/dc/elements/1.1/';
    public static final String NS_DC_TERMS          = 'http://purl.org/dc/terms/';

    // Schema XML Namespaces
    public static final String NS_SPREADSHEET_ML    = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
    public static final String NS_OFFICE_DOC_RELS   = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
    public static final String NS_OFFICE_DOC_PROP   = 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties';
    public static final String NS_CONTENT_TYPES     = 'http://schemas.openxmlformats.org/package/2006/content-types';
    public static final String NS_RELATIONSHIPS     = 'http://schemas.openxmlformats.org/package/2006/relationships';

    // Relationship XML namespaces
    public static final String NS_REL_SHRD_STRS     = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings';
    public static final String NS_REL_OFFICE_DOC    = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument';
    public static final String NS_REL_WORKSHEET     = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet';
    public static final String NS_REL_STYLES        = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles';
    public static final String NS_REL_EXT_PROP      = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties';

    // Package XML Namespaces
    public static final String NS_REL_CORE_PROP     = 'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties';
    public static final String NS_MTD_CORE_PROP     = 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties';
}