Feature: CSVlint API

  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
    Given the fixture "csvs/warnings.csv" is available at the URL "http://example.org/warnings.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"

  Scenario: View valid validation as JSON
    Given I have already validated the URL "http://example.org/test.csv"
    When I send and accept JSON
    And I send a GET request to view the validation
    Then the response status should be "200"
    And the JSON response should have "$..version" with the text "0.1"
    And the JSON response should have "$..licence" with the text "http://opendatacommons.org/licenses/odbl/"
    And the JSON response should have "$..validation..CSV" with the text "http://example.org/test.csv"
    And the JSON response should have "$..validation..state" with the text "valid"
    And the JSON response should have "$..validation..errors[*]" with a length of 0
    And the JSON response should have "$..validation..warnings[*]" with a length of 0
    And the JSON response should have "$..validation..info[*]" with a length of 0

  Scenario: View validation with errors as JSON
    Given I have already validated the URL "http://example.org/errors.csv"
    When I send and accept JSON
    And I send a GET request to view the validation
    Then the response status should be "200"
    And the JSON response should have "$..validation..state" with the text "invalid"
    And the JSON response should have "$..validation..errors[*]" with a length of 1
    And the JSON response should have "$..validation..errors[0].type" with the text "ragged_rows"
    And the JSON response should have "$..validation..errors[0].category" with the text "structure"
    And the JSON response should have "$..validation..errors[0].row" with the text "3"

  Scenario: View validation with warnings as JSON
    Given I have already validated the URL "http://example.org/warnings.csv"
    When I send and accept JSON
    And I send a GET request to view the validation
    Then the response status should be "200"
    And the JSON response should have "$..validation..state" with the text "warnings"
    And the JSON response should have "$..validation..warnings[*]" with a length of 1
    And the JSON response should have "$..validation..warnings[0].type" with the text "check_options"
    And the JSON response should have "$..validation..warnings[0].category" with the text "structure"

  Scenario: View validation with info messages as JSON
    Given I have already validated the URL "http://example.org/info.csv"
    When I send and accept JSON
    And I send a GET request to view the validation
    Then the response status should be "200"
    And the JSON response should have "$..validation..state" with the text "valid"
    And the JSON response should have "$..validation..info[*]" with a length of 1
    And the JSON response should have "$..validation..info[0].type" with the text "nonrfc_line_breaks"
    And the JSON response should have "$..validation..info[0].category" with the text "structure"

  Scenario: View recent validations as JSON
    Given I have already validated the URL "http://example.org/test.csv"
    And I have already validated the URL "http://example.org/errors.csv"
    And I have already validated the URL "http://example.org/warnings.csv"
    And I have already validated the URL "http://example.org/info.csv"
    When I send and accept JSON
    And I send a GET request to "/validation"
    Then the response status should be "200"
    And the JSON response should have "$..version" with the text "0.1"
    And the JSON response should have "$..licence" with the text "http://opendatacommons.org/licenses/odbl/"
    And the JSON response should have "$.._links..self" with the text "http://example.org/validation?page=1"
    And the JSON response should have "$.._links..first" with the text "http://example.org/validation?page=1"
    And the JSON response should have "$.._links..last" with the text "http://example.org/validation?page=1"
    And the JSON response should have "$..validations[*]" with a length of 4

  Scenario: View a package as JSON
    Given I have a package with the following URLs:
      | http://example.org/test.csv     |
      | http://example.org/errors.csv   |
      | http://example.org/warnings.csv |
      | http://example.org/info.csv     |
    When I send and accept JSON
    And I send a GET request to view the package
    Then the response status should be "200"
    And the JSON response should have "$..version" with the text "0.1"
    And the JSON response should have "$..licence" with the text "http://opendatacommons.org/licenses/odbl/"
    And the JSON response should have "$..package..validations[*]" with a length of 4
