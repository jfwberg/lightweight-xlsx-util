/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           January 2025
 * @copyright      (c) 2026 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class containing utilities for Apex Unit Testing
 */
@IsTest
@TestVisible
private with sharing class TestUtil {
    
    // Messages
    @TestVisible
    private static final String EXCEPTION_SAFEGUARD_MESSAGE = 'This part of the test should not be reached due to an exception that was supposed to be thrown.';
    
    @TestVisible
    private static final String EXCEPTION_ASSERTION_MESSAGE = 'Unexpected exception message';
}