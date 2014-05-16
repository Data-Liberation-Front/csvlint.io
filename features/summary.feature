Feature: Validation Summary
  In order to identify common CSV problems
  As a data publisher
  I want to view a summary of errors
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
  
  Scenario: View JSON statistics
    Given I have already validated the URL "http://example.org/test.csv"
    And that a Summary has been generated
    When I send and accept JSON
    And I send a GET request to view the statistics
    Then the response status should be "200"
    And the JSON response should have "$..sources" with the text "1"

