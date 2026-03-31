/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           March 2026
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class holding the XLSX to LLM Text Demo Constants
 *
 */
public with sharing class FlowConstant {

    // Error messages
    public static final String MSG_CHOICE_SET_TO_INTEGER_ERROR  = 'Unknown Error Converting Flow Choice Set to Integer List: "{0}"';
    public static final String MSG_GET_WS_LIST_UNKNOWN_ERROR    = 'An unexpected error occurred whilst processing the ContentDocument. Exception Message: "{0}"';
    public static final String MSG_REQUEST_PARAM_REQUIRED       = 'Invalid input: The requests parameter cannot be empty.';
    public static final String MSG_CONTENT_DOCUMENT_ID_REQUIRED = 'A ContentDocumentId is required.';
    public static final String MSG_INVALID_CONTENT_DOCUMENT_ID  = 'The provided Content Document Id is invalid.';
    public static final String MSG_XLSX_EXTENSION_EXCEPTION     = 'The content document extension is invalid. Only the "xlsx" extension is supported';
}