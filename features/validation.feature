Feature: CSV Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "schemas/valid.json" is available at the URL "http://example.org/schema.json"
    Given the fixture "schemas/invalid.json" is available at the URL "http://example.org/bad_schema.json"
    
  Scenario: Enter a URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    
  Scenario: Enter a URL and a schema URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And I should see my schema URL

  Scenario: Bad schema
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/bad_schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Invalid schema"

  Scenario: Upload a file for validation
    When I go to the homepage
    And I attach the file "valid.csv" to the file field
    And I press "Upload and validate"
    Then I should see a page of validation results