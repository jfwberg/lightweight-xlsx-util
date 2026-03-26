/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that holds methods to create the XLSX file from a builder class instance
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Build {

    /**
     * @description Method to build the XLSX builder as a Blob
     *              Use this to have th full freedom of how you 
     *              want to handle the file
     * @param b The builder class instance
     * @return      The XLSX as a EmailFileAttachment object
     */
    global static Blob asBlob(Builder b){
        return  XmlPackageBuilder.getPackage(b);
    }


    /**
     * @description Method to build the XLSX builder as a Document
     * @param b The builder class instance
     * @return      The XLSX as a Document object
     */
    global static Document asDocument(Builder b){

       // Sanitize the developer name and add X in case the number begins with a number
       String developerName = 'x_' + BuildUtil.getSanitizedFileName(b.fileName)
            ?.removeEnd(Constant.FULL_FILE_EXTENSION)
            ?.toLowerCase()
            ?.replaceAll(' ','_')
        ;

        // Create a new document
        Document d = new Document();
        d.Type              = Constant.FULL_FILE_EXTENSION.removeStart('.');
        d.Name              = b.fileName;
        d.DeveloperName     = developerName;
        d.Description       = b.coreProperties.description;
        d.FolderId          = Constant.DEF_FOLDER_ID;
        d.IsInternalUseOnly = true;
        d.IsPublic          = false;

        // Create the file body using the package builder
        d.body = XmlPackageBuilder.getPackage(b);

        // Combine the keywords and cut of after the keywords get too much
        d.keywords = (String.join(b.coreProperties.keywords,', ').length() > 255) ?
            String.join(b.coreProperties.keywords,', ').substring(0,255).substringBeforeLast(',') :
            String.join(b.coreProperties.keywords,', ')
        ;

        // Return the fully configured document
        // You can update the folder if you want later on
        return d;
    }


    /**
     * @description Method to build the XLSX builder as a ContentVersion
     * @param b The builder class instance
     * @return      The XLSX as a ContentVersion object
     */
    global static ContentVersion asContentVersion(Builder b){

        ContentVersion cv = new ContentVersion();

        // Create a new content version
        cv.Title        = b.coreProperties.title;
        cv.description  = b.coreProperties.description;
        cv.PathOnClient = BuildUtil.getSanitizedFileName(b.fileName);

        // Create the file body using the package builder
        cv.VersionData  = XmlPackageBuilder.getPackage(b);
        return cv;
    }


    /**
     * @description Method to build the XLSX builder as a EmailFileAttachment
     * @author      PawelWozniak (pawelw6@gmail.com)
     * @param b The builder class instance
     * @return      The XLSX as a EmailFileAttachment object
     */
    global static Messaging.EmailFileAttachment asEmailFileAttachment (Builder b) {

        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        emailFileAttachment.setFileName(BuildUtil.getSanitizedFileName(b.fileName));
        emailFileAttachment.setBody(XmlPackageBuilder.getPackage(b));
        emailFileAttachment.setContentType(Constant.CT_SHEET);

        return emailFileAttachment;
    }
}