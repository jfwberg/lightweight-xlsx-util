/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        January 2025
 * @copyright   (c) 2025 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description Execution of a performance test
 */
// -------------------------------------------------------
// -                  BUILD SYNC RESULTS                 -
// -------------------------------------------------------
// Sheets     Cols     Rows      Cells  Generation   Build --> After improvement
//      1       25     7250    181,250      3712ms  1900ms --> 187k (1*25*7500)
//      2       25     4062    203,100      5552ms  3808ms --> 300k (2*25*6000)
//      3       25     2625    196,875      5690ms  3608ms --> 243k (3*25*3250)
//      4       25     2000    200,000      5463ms  3830ms --> 250k (4*25*2500)
//      5       25     1650    206,250      5706ms  3835ms --> 250k (5*25*2000)
xlsx.BuilderPerformanceTest.run(5,10,1000);


// -------------------------------------------------------
// -                 BUILD ASYNC RESULTS                 -
// -------------------------------------------------------
// Sheets     Cols     Rows      Cells  Generation   Build
//      1       25    14500    362,500      6340ms  3419ms
//      2       25     8125    406,250      8185ms  4085ms
//      3       25     5250    393,750      8812ms  4672ms
//      4       25     4000    400,000      7634ms  4144ms
//      5       25     3300    412,500      9067ms  3992ms
xlsx.BuilderPerformanceTest.runAsync(2,25,8125);