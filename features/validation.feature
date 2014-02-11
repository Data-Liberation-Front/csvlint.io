Feature: CSV Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    
  Scenario: Enter a URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And my url should be persisted in the database
    
  Scenario: Upload a file for validation
    When I go to the homepage
    And I attach the file "valid.csv" to the file field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
  
  Scenario: Upload a file with warnings
    When I go to the homepage
    And I attach the file "warnings.csv" to the file field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
    And the database record should have the type "ragged_rows"