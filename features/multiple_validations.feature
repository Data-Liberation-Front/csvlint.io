@javascript
Feature: Multiple CSV Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test2.csv"
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test3.csv"
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test4.csv"
    
  Scenario: Enter multiple URLs for validation
    When I go to the homepage
    And I enter the following urls:
      |http://example.org/test.csv|
      |http://example.org/test2.csv|
      |http://example.org/test3.csv|
      |http://example.org/test4.csv|
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "http://example.org/test.csv"
    And I should see "http://example.org/test2.csv"
    And I should see "http://example.org/test3.csv"
    And I should see "http://example.org/test4.csv"