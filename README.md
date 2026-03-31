# Salesforce Apex - XLSX Util
A Lightweight Salesforce Apex utility to read and write basic XLSX files based on the ECMA-376 standard fully on platform without the need for any external API calls for processing.

The application is based on the `ZipWriter` and `ZipReader` classes from the compression namespace. Due to this the library requires API version 63.0 (Spring '25)+

We are limited to the Apex governor limits, but nonetheless it can write pretty large worksheets synchronously and even larger asynchronously. If you need extremely large or complex files, you're probably better off using Salesforce Document Builder or a 3rd party application like Conga Composer.

The library comes with the most common functionalities like freezing rows, merging cells, create hyperlinks and the majority of the styling options. There is no support for table styles, charts or images at this time.


## Blog
- [Salesforce developer Blog: Reading Excel Files Using the Apex Zip Functionality](https://developer.salesforce.com/blogs/2025/02/reading-excel-files-using-the-apex-zip-functionality)
- [Medium Article: Creating Excel (XLSX) Files Using The New Apex Zip Functionality](https://medium.com/@justusvandenberg/creating-excel-xlsx-files-using-the-new-apex-zip-functionality-8372c6689a10)
- [Medium Article: From Excel to Prompt Templates: Making Spreadsheet Data LLM-Ready with Salesforce Agentforce ](https://medium.com/@justusvandenberg/from-excel-to-prompt-templates-making-spreadsheet-data-llm-ready-with-salesforce-agentforce-51afb8472bae)

## Package Info
| Info | Value | ||
|---|---|---|---|
|Name|Lightweight - XLSX Util||
|Version|0.8.0||
|**Managed** | <li>`sf package install --wait 30 --security-type AllUsers --package 04tP3000001pV7dIAE`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001pV7dIAE`</li> | [Install in production](https://login.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001pV7dIAE) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001pV7dIAE)|
|**Unlocked**| <li>`sf package install --wait 30 --security-type AllUsers --package 04tP3000001pVZ3IAM`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001pVZ3IAM`</li> | [Install in production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001pVZ3IAM)          | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001pVZ3IAM)|


## Optional LLM Util Package Info
| Info | Value | ||
|---|---|---|---|
|Name|Lightweight - XLSX to LLM Util||
|Version|0.2.0||
|**Managed** | <li>`sf package install --wait 30 --security-type AllUsers --package 04tP3000001pV9FIAU`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001pV9FIAU`</li> | [Install in production](https://login.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001pV9FIAU) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001pV9FIAU)|

## Parse Excel files
Parsing is done using the `Parse` class in the `xlsx` namespace. We can parse to two different formats: a *multi dimensional array* or a *list of maps*. In the array format the first list represents the worksheet, the child the rows and the grand child the cells.
In the Map List option, each map represents a worksheet and the Map Key equals the cell name like "A1" and the value the corresponding value object.

The basic method outline is as below:
```java
// OUTPUT AS MULTIDIMENSIONAL ARRAY
Object[][][] xlsxDataArray = xlsx.Parse.toArray(Map<String,Compression.ZipEntry> entries){}

// OUTPUT AS MAP
List<Map<String,Object>> xlsxDataMap = xlsx.Parse.toMap(Map<String,Compression.ZipEntry> entries){}
```

The entries parameter is the unzipped blob data represented in a map with entries `Map<String,Compression.ZipEntry>`. The blob data can come from a file, attachment or web service. As long as it is a valid XLSX file.
```java
// The document Id
Id documentId = '015Qz000004jf7yIAA';

// Query a document for content, this is a compressed zip file body
Blob xlsxBlobData = [SELECT body FROM Document WHERE Id = :documentId LIMIT 1]?.Body;

// Create a new zip reader instance
Compression.ZipReader reader = new Compression.ZipReader(xlsxBlobData);

// Get a map with entries
Map<String,Compression.ZipEntry> entries = reader.getEntriesMap();
```

To preserve heap size this can be simplyfied by putting all statements inline instead of separate variables:

```java
// As multi dimensional array
Object[][][] xlsxDataArray = xlsx.Parse.toArray(
    new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Qz000004jf7yIAA' LIMIT 1]?.Body
    ).getEntriesMap()
);


// As data map
List<Map<String,Object>> xlsxDataMap = xlsx.Parse.toMap(
    new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Qz000004jf7yIAA' LIMIT 1]?.Body
    ).getEntriesMap()
);
```

## Parsing for LLMs / Salesforce Agentforce

LLMs are notoriously bad at reading the complex structure of XLSX files. To get around this I created a custom output format that is easy to interpret by LLMs, small on tokens and it keeps the cposition rather than context. The LLM can infer the context based on the flat locations.

```java
// As multi dimensional array
String llmCompatibleText = xlsx.Parse.toLlmText(
    new Compression.ZipReader(
        [SELECT body FROM Document WHERE Id = '015Qz000004jf7yIAA' LIMIT 1]?.Body
    ).getEntriesMap()
);
```


## Parse Methods
For different use cases you can use different parse methods each with advantages. Using the `Dom.Document` class for reading XML is a lot faster than the `XmlStreamWriter` but also limited due to the large heap size it uses.

The default output order for the `toArray()` methods is `Worksheet.Column.Row`. This follows the Excel cell format like A1, A2, ALL999 and is ideal when you work with **columns**. The `toArrayInverted()` methods use the `Worksheet.Row.Column` order. This makes working with **record data** (i.e. CSV) a lot easier.

The `xlsx.Parse` class is used to parse an XLSX file body from an unzipped file body

### Array Parse Methods

|Return type| Method signature| Use for |
|---|---|---|
| `Object[][][]`             |`xlsx.Parse.toArray(Map<String,Compression.ZipEntry> entries)`                                            | Large files, CSV like data, Output format is Worksheets.Columns.Rows |
| `Object[][][]`             |`xlsx.Parse.toArray(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`               | Large files, CSV like data, specific sheets only, Output format is Worksheets.Columns.Rows |
| `Object[][][]`             |`xlsx.Parse.toArrayDomDoc(Map<String,Compression.ZipEntry> entries)`                                      | Small files, CSV like data, Output format is Worksheets.Columns.Rows  |
| `Object[][][]`             |`xlsx.Parse.toArrayDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`         | Small files, CSV like data, specific sheets only, Output format is Worksheets.Columns.Rows |
| `Object[][][]`             |`xlsx.Parse.toArrayInverted(Map<String,Compression.ZipEntry> entries)`                                    | Large files, CSV like data, Output format is Worksheets.Rows.Columns |
| `Object[][][]`             |`xlsx.Parse.toArrayInverted(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`       | Large files, CSV like data, specific sheets only, Output format is Worksheets.Rows.Columns |
| `Object[][][]`             |`xlsx.Parse.toArrayInvertedDomDoc(Map<String,Compression.ZipEntry> entries)`                              | Small files, CSV like data, Output format is Worksheets.Rows.Columns  |
| `Object[][][]`             |`xlsx.Parse.toArraInvertedyDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)` | Small files, CSV like data, specific sheets only, Output format is Worksheets.Rows.Columns |

### Map Parse Methods

|Return type| Method signature| Use for |
|---|---|---|
| `List<Map<String,Object>>` |`xlsx.Parse.toMap(Map<String,Compression.ZipEntry> entries)`                                              | Large files, Data based on cell names |
| `List<Map<String,Object>>` |`xlsx.Parse.toMap(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`                 | Large files, Data based on cell names, specific sheets only |
| `List<Map<String,Object>>` |`xlsx.Parse.toMapDomDoc(Map<String,Compression.ZipEntry> entries)`                                        | Small files, Data based Cell Name |
| `List<Map<String,Object>>` |`xlsx.Parse.toMapDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`           | Small files, Data based on cell namese, specific sheets only |

### Sheet name / Array Map Parse Methods

|Return type| Method signature| Use for |
|---|---|---|
| `Map<String, Object[][]>` |`xlsx.Parse.toSheetNameArrayMap(Map<String, Compression.ZipEntry> entries`                                         | Large files, CSV like data, Output format is Worksheets.Columns.Rows based on the sheet name|
| `Map<String, Object[][]>` |`xlsx.Parse.toSheetNameArrayMap(Map<String, Compression.ZipEntry> entries, Set<Integer> selectedSheets)`           | Large files, CSV like data, specific sheets only, Output format is Worksheets.Columns.Rows based on the sheet name|
| `Map<String, Object[][]>` |`xlsx.Parse.toSheetNameArrayInvertedMap(Map<String, Compression.ZipEntry> entries`                                 | Large files, CSV like data, Output format is Worksheets.Rows.Columns based on the sheet name|
| `Map<String, Object[][]>` |`xlsx.Parse.toSheetNameArrayInvertedMap(Map<String, Compression.ZipEntry> entries, Set<Integer> selectedSheets)`   | Large files, CSV like data, specific sheets only, Output format is Worksheets.Rows.Columns based on the sheet name|


## Worksheet Name/Index Methods

|Return type| Method signature| Use for |
|---|---|---|
| `Map<String,Integer>`      |`xlsx.Parse.toWorksheetNameIndexMap(Map<String,Compression.ZipEntry> entries)`                            | You need to get the index based on the name of the worksheet |
| `Map<String,Integer>`      |`xlsx.Parse.toWorksheetNameIndexMap(Map<String,Compression.ZipEntry> entries,Set<Integer> selectedSheets)`| You need to get the index based on the name of the worksheet, specific sheets only |
| `Map<Integer,String>`      |`xlsx.Parse.toWorksheetIndexNameMap(Map<String,Compression.ZipEntry> entries)`                            | You need to get the name based on the index of the worksheet |
| `Map<Integer,String>`      |`xlsx.Parse.toWorksheetIndexNameMap(Map<String,Compression.ZipEntry> entries,Set<Integer> selectedSheets)`| You need to get the name based on the index of the worksheet, specific sheets only |

## LLM Methods
LLMs are notoriously bad at reading XLSX files. In order to help Salesforce's Agentforce to read XLSX files using prompt templates there are a few methods that convert the Excel sheet data into an LLM friendly format.
Note: This is very CPU intensive so massive files are not really supported.

|Return type| Method signature| Use for |
|---|---|---|
| `String` |`xlsx.Parse.toLlmText(Map<String,Compression.ZipEntry> entries)`                                    | Medium Files, You need to convert the output to an LLM fiendly format  |
| `String` |`xlsx.Parse.toLlmText(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)`       | Medium Files, You need to convert the output to an LLM fiendly format, specific sheets only |
| `String` |`xlsx.Parse.toLlmTextDomDoc(Map<String,Compression.ZipEntry> entries)`                              | Small Files,  You need to convert the output to an LLM fiendly format, specific sheets only |
| `String` |`xlsx.Parse.toLlmTextDomDoc(Map<String,Compression.ZipEntry> entries, Set<Integer> selectedSheets)` | Small Files,  You need to convert the output to an LLM fiendly format, specific sheets only |


## Build Methods

The `xlsx.Build` class is used to create an XLSX file from a `xlsx.Builder` class instance.

|Return type| Method signature| Use for |
|---|---|---|
|`Blob`                          |`xlsx.Build.asBlob(Builder b)`               | Building your XLSX file as a `Blob` Object|
|`Document`                      |`xlsx.Build.asDocument(Builder b)`           | Building your XLSX file as a `Document` Object|
|`ContentVersion`                |`xlsx.Build.asContentVersion(Builder b)`     | Building your XLSX file as a `ContentVersion` Object|
|`Messaging.EmailFileAttachment` |`xlsx.Build.asEmailFileAttachment(Builder b)`| Building your XLSX file as a `Messaging.EmailFileAttachment` Object|


## Builder Methods

The `xlsx.Builder` class is used to setup/configure the entire XLSX document. Use this to add worksheets, rows and cells but also configure the document name etc.
Making changes to anything in the sheets uses the worksheet index (`wi`), column index (`ci`) and row index (`ri`) parameters. These are the zero indexes so cell A1 on Sheet1 is set as [0][0][0].

|Return type| Method signature| Use for |
|---|---|---|
|`void`     |`setUseSharedStrings(Boolean value)`                       | Enable or disable shared strings. Shared strings is recommended and enabled by default.|
|`void`     |`setIncludeDefaultStyles(Boolean value)`                   | Enable the Lightweight - XLSX Util standard styles |
|`void`     |`setFileName(String value)`                                | Setting a custom name for the output file, does not have to end in .xlsx|
|`void`     |`setTitle(String value)`                                   | Setting a document title|
|`void`     |`setSubject(String value)`                                 | Setting a document subject|
|`void`     |`setDescription(String value)`                             | Setting a document description|
|`void`     |`addKeyword(String value)`                                 | Adding a document keyword, A max of 255 characters for all keywords is in place|
|`Integer`  |`addWorksheet(String name)`                                | Adds a new worksheet with a name (max 31 characters). Set the name param to NULL for an auto generated name like in Excel (i.e. sheet1, sheet2 etc.) |
|`Integer`  |`addWorksheet(String name, BooleanwriteDimensionElement)`  | Same as `addWorksheet(name) but with the boolean option to disable the writing of the "dimension" element on worksheets. Intended for testing purposes.|
|`void`     |`prePadWorksheet(Integer wi, Integer ci, Integer ri)`      | If you know the max number of rows and columns you can use this method for performance optimization|
|`void`     |`setVisible(Integer wi, Boolean state)`                        | Set a worksheet visible or invisible|
|`void`     |`setTabColor(Integer wi, String colorCode)`                    | Set a custom tab color (6 digit HEX code)|
|`void`     |`setAutoFilter(Integer wi, Boolean value)`                     | Enable an auto filter on the columns|
|`void`     |`setFreezeRows(Integer wi, Integer numberOfRows)`              | Set a number of rows to freeze on a worksheet|
|`void`     |`setFreezeColumns(Integer wi, Integer numberOfColumns)`        | Set a number of columns to freeze on a worksheet|
|`void`     |`addTextCell(Integer wi, Integer ci, Integer ri, String v)`                | Add a Text cell|
|`void`     |`addNumberCell(Integer wi, Integer ci, Integer ri, Integer v)`             | Add an Integer cell|
|`void`     |`addNumberCell(Integer wi, Integer ci, Integer ri, Decimal v)`             | Add a Decimal cell|
|`void`     |`addBooleanCell(Integer wi, Integer ci, Integer ri, Boolean v)`            | Add a Boolean cell|
|`void`     |`addFormulaCell(Integer wi, Integer ci, Integer ri, Object v, String f)`   | Add a Formula cell (text for value)|
|`void`     |`addTextCell(Integer wi, Integer ci, Integer ri, String v, Integer s)`             | Add a Text cell with style index|
|`void`     |`addNumberCell(Integer wi, Integer ci, Integer ri, Integer v, Integer s)`          | Add an Integer cell with style index|
|`void`     |`addNumberCell(Integer wi, Integer ci, Integer ri, Decimal v, Integer s)`          | Add a Decimal cell with style index|
|`void`     |`addBooleanCell(Integer wi, Integer ci, Integer ri, Boolean v, Integer s)`                 | Add a Boolean cell with style index|
|`void`     |`addFormulaCell(Integer wi, Integer ci, Integer ri, Object v, String f, Integer s)`        | Add a Formula cell with style index|
|`void`     |`addMergeCell(Integer wi, Integer startCi, Integer startRi, Integer endCi, Integer endRi))`| Merge cells together. Note: merge cells cannot overlap or your sheet won't work.|
|`void`     |`addHyperLink(Integer wi, Integer ci, Integer ri, String location, String display)`        | Add a hyperlinked cell, note you need to add a text cell first before adding a hyperlink|
|`void`     |`setRowStyle(Integer wi, Integer ri, Integer s)`               | Set a row's style index |
|`void`     |`void setRowHeight(Integer wi, Integer ri, Decimal h)`         | Set a row's height |
|`void`     |`setRowHidden(Integer wi, Integer ri, Boolean v)`              | Set a row's visibility |
|`void`     |`setColStyle(Integer wi, Integer ci, Integer s)`               | Set a column's style index |
|`void`     |`setColWidth(Integer wi, Integer ci, Decimal w)`               | Set a column's height |
|`void`     |`setColHidden(Integer wi, Integer ci, Boolean h)`              | Set a column's visibility|
|`void`     |`setCellStyle(Integer wi, Integer ci, Integer ri,Integer s)`   | Set a cell's style after it has been created |

## Styles Methods

The `xlsx.StylesBuilder` class is used to create custom styles and add them to a `xlsx.Builder` class instance.
The `add methods` return an `index`, the indexes for number formats, fonts, files borders and alignments need to be used as the input parameters for the `addCellStyle()` method to create a unique style. Indexes can be reused to mix and match styles.

|Return type| Method signature| Use for |
|---|---|---|
|`Integer`              |`addNumberFormat(Builder b, Integer numFmtId, String formatCode)`                                          |Add a custom number format, you'll rarely need this one|
|`Integer`              |`addFont(Builder b, Integer sz, String name, String rgb, Boolean bold, Boolean italic, Boolean underline)` | Add a custom font with size color and decoration|
|`Integer`              |`addFill(Builder b, String patternType, String fgColor, String bgColor)`                                   |Add a fill with a pattern, foreground and background color|
|`Map<String,String>`   |`borderConfig(String style, String color)`                                                                 |Attribute for the `addBorder` method|
|`Integer`              |`addBorder(Builder b, Map<String,String> left, Map<String,String> right, Map<String,String> top, Map<String,String> bottom)`   | Add a custom border with a style and a color. Valid values are: |
|`Integer`              |`addAlignment(Builder b, String horizontal, String vertical, Integer textRotation, Boolean wrapText)`                          | Add a custom alignment for the cell. Valid values are: |
|`Integer`              |`addCellStyle(Builder b, Integer numFmtId, Integer fontId, Integer fillId, Integer borderId, Integer alignmentId)`             | Combine the indexes from previous methods to create a unique style index that can be used in for row, columns and cells.|
|`Integer`              |`getHeaderStyleIndex(Integer ci, Integer startCi, Integer endCi)`                          | If you include the standard styles, use this method to get the index for a header of a "table". Set the ci, the start ci of teh table and the last ci of the table.|
|`Integer`              |`getMainStyleIndex(Integer ci, Integer ri, Integer startCi, Integer endCi, Integer endRi)` |If you include the standard styles, use this method to get the index for the rows (including the bottom row). Set the first and last indexes of the cell range. |


## CommonUtil Methods

The `xlsx.CommonUtil` class contains utilities that help you with the setup of a `xlsx.Builder` class instance. 

|Return type| Method signature| Use for |
|---|---|---|
|`String`     | `columnNameFromColumnIndex(Integer columnIndex)`   |Translate a column `index` to a column name. I.e. 0=A and 4=E etc.|
|`Integer`    | `columnNumberFromColumnName(String columnName)`    |Get a column `number` from a column name. I.e A=1 and E=5|
|`String`     | `cellName(Integer columnIndex, Integer rowIndex)`  |Get cell name based on row and column `index`. Ie,e 0,0 = A1, 4,4 = E5 etc. This is handy if you work with formulas|
|`String`     | `randomHtmlHexColorCode()`                         |Creates a random 6 digit HEX code that can be used in tabs. Handy for testing purposes to distinguish between tabs.|
|`Datetime`   | `getTimestamp()`                                   |Get the timestamp that is used when creating an `xlsx.Builder` class instance. This ensures you use the same timestamp through out.|
|`String`     | `getTimestampString()`                             |Get the timestamp as a string that can be used in a file name|
|`String`     | `getStaticResourceBody(String staticResourceName)` |Get's the body of a static resource based on the name|


## Exceptions
In order to handle Exceptions there are two Exception classes
|Exception| Thrown when |
|---|---|
|`xlsx.ParseException`| Any issue happens during the parsing of an XLSX file|
|`xlsx.BuildException`| Any issue that happens during the build of an XLSX file|


## Examples
The [`examples folder`](examples) contains a number of example implementation for both parsing and building XLSX files. Use these as a guide of how to create the files.

### Parse Examples
|File| Description | Additional Info|
|---|---|---|
|[10_Parse_Document.apex](examples/parser/10_Parse_Document.apex)                   | Example to parse a an XLSX file stored as Document Object         ||
|[11_Parse_ContentDocument.apex](examples/parser/11_Parse_ContentDocument.apex)     | Example to parse a an XLSX file stored as Attachment Object       ||
|[12_Parse_Attachment.apex](examples/parser/12_Parse_Attachment.apex)               | Example to parse a an XLSX file stored as ContentVersion Object   ||
|[13_Parse_To_CSV.apex](examples/parser/13_Parse_To_CSV.apex)                       | Example to parse a an XLSX file and convert it to a CSV file (one for each worksheet)        ||
|[14_Parse_To_sObject_List.apex](examples/parser/14_Parse_To_sObject_List.apex)     | Example to parse a an XLSX to an sObject list. This allows you to handle the data as records ||
|[15_Parse_To_LLM_Text.apex](examples/parser/15_Parse_To_LLM_Text.apex)             | Example to parse a an XLSX to an LLM Optimised output format ||

### Build Examples
|File| Description | Additional Info|
|---|---|---|
|[00_Twelve_Days_Of_Christmas.apex](examples/builder/00_Twelve_Days_Of_Christmas.apex)| Calculate how many gifts you get on the N day of Christmas.   ||
|[01_sObject_Documentation.apex](examples/builder/01_sObject_Documentation.apex)    | Export your data model to Excel                               ||
|[02_SOQL_With_Child_Queries.apex](examples/builder/02_SOQL_With_Child_Queries.apex)| Export a query with sub queries and metadata relationship information to Excel. Ideal for Archiving purposes                          |[Blog](https://medium.com/@justusvandenberg/dynamically-handle-salesforce-soql-subquery-response-data-using-apex-8130bd0622aa)|
|[03_Data_Migration_Guide.apex](examples/builder/03_Data_Migration_Guide.apex)      | Creates a document with all sObjects in your org that contain data and puts in the in the correct loading order with metadata analysis|[Blog](https://medium.com/@justusvandenberg/programmatically-determine-the-object-loading-order-for-salesforce-data-migrations-using-apex-1f65841531fb)|
|[04_Limit_Usage.apex](examples/builder/04_Limit_Usage.apex)                        | Export your org's limit usage to Excel                        ||
|[05_Record_Count.apex](examples/builder/05_Record_Count.apex)                      | Export your org's data usage details to Excel                 ||
|[06_Styling.apex](examples/builder/06_Styling.apex)                                | Example on how to style your Excel Sheets                     ||
|[07_Hyperlinks.apex](examples/builder/07_Hyperlinks.apex)                          | Example on how to use hyperlinks                              ||
|[08_List_Metadata.apex](examples/builder/08_List_Metadata.apex)                    | Export a list of metadata types like ApexClass, Profiles to a multi tab Excel workbook |[Blog](https://medium.com/@justusvandenberg/a-lightweight-salesforce-metadata-api-apex-library-47c0b4c34131)|
|[09_Minimal_Required.apex](examples/builder/09_Minimal_Required.apex)              | An example the absolute minimum code to create an Excel Sheet ||

# Roadmap
There is not really a roadmap as of now, but a few things I am planning to add are:
-   Native support to parse files directly to CSV for better performance than the example in the examples folder (i.e. `xlsx.Parse.toCSV()`)
    The main purpose for this is to accommodate the loading of data to Data Cloud.
-   Native support to parse files directly to sObjects for better performance than the example in the examples folder (i.e. `xlsx.Parse.toSObject()`)
    Generic SObject Parsing is quite tricky and it would require to check the metadata to see if objects / fields exist. Adding support for this comes with a lot of potential issues as so much can go wrong with crappy data in the wrong field types for example. But it would be useful and the boiler plate code has bene written in the examples.

# Additional resources
## XLSX Performance
- [Apex Zip Support Performance Test](https://medium.com/@justusvandenberg/apex-zip-support-performance-test-03bef1539ed6)
- [Salesforce Apex Optimization: Large Strings vs Heap Size and CPU Time](https://medium.com/@justusvandenberg/salesforce-apex-optimization-large-strings-vs-heap-size-and-cpu-time-66ee6621ec26)
- [Salesforce Apex Optimization: Maps vs Multi-Dimensional Arrays](https://medium.com/@justusvandenberg/salesforce-apex-optimization-maps-vs-multi-dimensional-arrays-lists-3703b9aaaf79)

## XLSX Examples
- [A Lightweight Salesforce Metadata API Apex Library](https://medium.com/@justusvandenberg/a-lightweight-salesforce-metadata-api-apex-library-47c0b4c34131)
- [Programmatically Determine The Object Loading Order For Salesforce Data Migrations Using Apex](https://medium.com/@justusvandenberg/programmatically-determine-the-object-loading-order-for-salesforce-data-migrations-using-apex-1f65841531fb)
- [Dynamically Handle Salesforce SOQL Subquery Response Data Using Apex](https://medium.com/@justusvandenberg/dynamically-handle-salesforce-soql-subquery-response-data-using-apex-8130bd0622aa)

## XLSX Formatting
- [ECMA-376 Standard](https://ecma-international.org/publications-and-standards/standards/ecma-376/)
- [C-REX.net (Detailed documentation of the XML structures)](https://c-rex.net/samples/ooxml/e1/Whitepaper/structure.html)
- [Open XML Explained by Wouter van Vugt (Whitepaper with the high level details of the XML structure)](https://www.brandwares.com/downloads/Open-XML-Explained.pdf)

# Getting started guide
## Set up the document properties
Each new file you create starts with an `xlsx.Builder` class instance. The builder is used to "set up" the entire file.
Let's start with a verbose example where we set the string handling, if we want to include some app specific default styles and the file properties.
```java
// Create a new builder
xlsx.Builder b = new xlsx.Builder();

// Because we have repetition for each sObject (field names),
// use shared strings instead of inline strings for a better overall performance
// Defaults to true, so not required
b.setUseSharedStrings(true);

// This option creates the default set of "table" styles
// Can be used to use a default styling for all sheets, (will take a small performance hit)
// Defaults to false
b.setIncludeDefaultStyles(true);
 
// Set the name of the xlsx file
b.setFileName(xlsx.CommonUtil.getTimestampString() + '_example.xlsx' );

// Set file properties
b.setTitle('Example ('+xlsx.CommonUtil.getTimestampString()+ ')');
b.setSubject('Example subject');
b.setDescription('Example description');
b.addKeyword('Example');
b.addKeyword('Additional Example');
```

## Setup worksheets
Data is managed by using a multi-dimensional array with zero based index for all worksheets. Each worksheet has a worksheet index (`wi`), column index (`ci`) and row index (`ri`).
This means that for example in Apex a cell located at [0][0][0] is located at "A1" in the first worksheet and [1][1][1] is located at "B2" in the second worksheet etc. This makes coding and array looping a whole lot easier. But it is something to keep in mind when adding data to the grid.
I tried to match it to Excel number at first, but the +1/-1 drove me completely insane, so I reverted back to "good old starting at 0".

So now that we have our file set up, lets start adding worksheets. We add a worksheet using the `addWorksheet(String name)` method. This method return an integer with the sheet index (`wi`) of the sheet you have added. In case you don't want to manually keep track you can add the index to a variable.
Worksheet names cannot have funky characters and not be longer than 31 characters. I have put some sanitization logic in place, but that might not be completely fool proof.

```java
// Get the worksheet index when adding it to the worksheet array
Integer wi0 = b.addWorksheet('My First Worksheet');
Integer ws1 = b.addWorksheet('My Second Worksheet');

// Give the worksheet tabs a nice color (These are are the Data Cloud Logo Colors in case you wonder)
// You use a HEX code and the tab index
b.setTabColor(wi0,'5E62A2');
b.setTabColor(wi1,'868ACA');

// We can freeze rows and columns by specifying the wi and the number of rows or
// columns we want to freeze
// Freeze top row
b.freezeRows(wi0, 1);
b.freezeRows(wsi1, 1);

// Freeze the left column
b.freezeColumns(wi0, 1);
b.freezeColumns(wi1, 1);

// Enable the filter options for the first row on both sheets
// You'll see that the filter will be applied for each column added
// It cannot be more specific, it's all or none.
b.enableAutoFilter(wi0);
b.enableAutoFilter(wi1);
```

## Add Cells

## Add Merge Cells and Hyperlinks

## Add Styling

## Build as Document or ContentVersion


