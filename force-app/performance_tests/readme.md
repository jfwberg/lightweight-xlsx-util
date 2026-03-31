# Performance Tests
The performance tests have a package dependency you need to install first in order to store the debug output.

These tests should run the tests with a low debug level, hence storing the output async was the way to go.
Note: These are not complex and detailed tests, it's more to get an idea of how much you can throw at it.

Follow the below steps


## Installation

- Install the *Lightweight - Debug Util(0.2.0-1)* package<br/> `sf package install --package "04tP3000001pTqbIAE" -w 30`

- Assign the Permission set<br/> `sf org assign permset --name "Lightweight_Debug_Util"`

- Deploy the classes (from the project root directory) <br/> `sf project deploy start --source-dir force-app/performance_tests`

- Execute Builder Anonymous Apex (from the project root directory) <br/> `force-app/performance_tests/builder/builder_performance_test.apex` 

- Execute Parser Anonymous Apex (from the project root directory)<br/> `force-app/performance_tests/parser/parser_performance_test.apex`

- Update the numbers in the anonymous apex files to your needs

- See the results in the *Debug Logs* sObject, there is a tab for that