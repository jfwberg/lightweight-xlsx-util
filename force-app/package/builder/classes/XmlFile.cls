/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class representing an XML file
 */
public with sharing class XmlFile {

    public String folder;
    public String fileName;
    public Blob   fileBody;

    /**
     * @description Default constructor
     * @param folder   The foldername where the file will be stored
     * @param fileName The file name
     * @param fileBody The file body
     */
    public XmlFile(String folder, String fileName, Blob fileBody){
        this.folder  = folder;
        this.fileName= fileName;
        this.fileBody= fileBody;
    }
}