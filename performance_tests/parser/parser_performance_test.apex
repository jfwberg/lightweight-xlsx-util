/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        January 2025
 * @copyright   (c) 2026 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description Execution of a performance test
 */
// -------------------------------------------------------
// -            PARSE TO ARRAY SYNC RESULTS             -
// -------------------------------------------------------
// Sheets   Cols    Rows      Cells    Parse Tm  Handle Tm
//      1     25    7250    181,250    11,412ms        195
//      2     25    4062    203,100     6,795ms        221
//      3     25    2625    196,875     4,524ms         78
//      4     25    2000    200,000     3,587ms         51 <-- check with no
//      5     25    1650    206,250     2,740ms         40
xlsx.ParserPerformanceTest.parseToArray(4, 25, 2000, '015Pt000009754DIAQ');



// -------------------------------------------------------
// -            PARSE TO ARRAY ASYNC RESULTS             -
// -------------------------------------------------------
// Sheets   Cols    Rows      Cells    Parse Tm  Handle Tm
//      1     25   14000    350,000    19,742ms        277
//      2     25    8000    400,000    13,162ms        221
//      3     25    5250    393,750     8,371ms        138
//      4     25    4000    400,000     6,516ms        101
//      5     25    3300    412,500     5,734ms         90
xlsx.ParserPerformanceTest.parseToArrayAsync(2, 25, 3500, '015Q1000004kO0DIAU');


// -------------------------------------------------------
// -              PARSE TO MAP SYNC RESULTS              -
// -------------------------------------------------------
// Sheets   Cols    Rows      Cells    Parse Tm  Handle Tm
//      1     25    7250    181,250    13,176ms        831
//      2     25    4062    203,100     7,244ms        447
//      3     25    2625    196,875     4,889ms        353
//      4     25    2000    200,000     3,838ms        230
//      5     25    1650    206,250     3,139ms        184
xlsx.ParserPerformanceTest.parseToMap(4, 25, 2000, '015Pt000009754DIAQ');


// -------------------------------------------------------
// -             PARSE TO MAP ASYNC RESULTS              -
// -------------------------------------------------------
// Sheets   Cols    Rows      Cells    Parse Tm  Handle Tm
//      1     25   14000    350,000    17,416ms        864
//      2     25    8000    400,000     8,000ms        569
//      3     25    5250    393,750     6,483ms        356
//      4     25    4000    400,000     4,939ms        240
//      5     25    3300    412,500     4,152ms        191
xlsx.ParserPerformanceTest.parseToMapAsync(5, 25, 3300,'015Qz000004m06hIAA');