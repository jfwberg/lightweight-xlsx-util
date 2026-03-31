/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Interface for classes that represent XML Elements
 */
public interface IXmlElement {

    /**
     * @description Method to write the element XML
     * @param x The XmlStreamWriter instance to add to
     */
    void writeXml(XmlStreamWriter x);
}