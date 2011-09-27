Feature: Test Report: Result Summary
In order to get high level over view of the test results,
As a QA Team Leader,
I want to see pass, fail and N/A totals. Additionally, I want to see run rate, pass rate and NFT index.

  Scenario: Result Summary for Functional Test Report
    Given I view a report with results: 5 Passed, 4 Failed, 2 N/A
    Then  I should see Result Summary:
      | Title                 | Result | [Explanation]                        |
      | Total test cases      |    11  |                                      |
      | Passed                |     5  |                                      |
      | Failed                |     4  |                                      |
      | N/A                   |     2  |                                      |
      | Run rate              |    82% | (Passed + Failed) / Total test cases |
      | Pass rate of total    |    45% | Passed / Total test cases            |
      | Pass rate of executed |    56% | Passed / (Total test cases - N/A)    |
    #And I should not see in Result Summary:
    #  | Title                 |
    #  | Measured              |
    #  | NFT Index             |

 Scenario: Result Summary for NFT Test Report
    Given I view a report with results:
      | Result         | Value   | Target  | Fail limit | [Explanation]                                 |
      | N/A            |         |   5 ms  |            | NFT Index:                             =   0% |
      | Measured       |   5 ms  |         |            | Doesn't affect to NFT Index                   |
      | Fail           |   7 ms  |   5 ms  |            | NFT Index: Target / Value              =  71% |
      | Fail           |  25 fps |  30 fps |            | NFT Index: Value  / Target             =  83% |
      | Pass           |  10 s   |   9 s   |   11 s     | NFT Index: Target / Value              =  90% |
      | Pass           |   8 s   |   9 s   |            | NFT Index: Min(100 %, Target / Value)  = 100% |

    Then  I should see Result Summary:
      | Title                 | Result | [Explanation]                                        |
      | Total test cases      |     6  |                                                      |
      | Passed                |     2  |                                                      |
      | Failed                |     2  |                                                      |
      | N/A                   |     1  |                                                      |
      | Measured              |     1  |                                                      |
      | Run rate              |    83% | (Total test cases - N/A) / Total test cases          |
      | Pass rate of total    |    40% | Passed / (Total test cases - Measured)               |
      | Pass rate of executed |    56% | Passed / (Total test cases - Measured - N/A)         |
      | NFT Index             |    69% | Sum(Test Case NFT Index) / Test Cases with NFT index |
