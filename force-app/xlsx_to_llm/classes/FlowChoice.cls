/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           March 2026
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class representing a Flow Choice Set ApexType
 *
 * @false-positive AvoidGlobalModifier      This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.

 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FlowChoice {
    
    @AuraEnabled 
    global String label; 
    
    @AuraEnabled 
    global String value; 

    global FlowChoice(String label, String value){
        this.label = label;
        this.value = value;
    }
}