@javascript
Feature: Background validation
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
    Given the fixture "csvs/revalidate.csv" is available at the URL "http://example.org/revalidate.csv"
  
  Scenario: Enter a URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    Then my CSV should be placed in a background job
    When I press "Validate"
    And I wait for the package to be created
    When the CSV has finished processing
    Then I should be redirected to my validation results
    And I should see a page of validation results
    And I should see my URL
    And my url should be persisted in the database