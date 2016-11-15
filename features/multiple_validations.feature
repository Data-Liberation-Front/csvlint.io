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
    Given the fixture "schemas/valid.json" is available at the URL "http://example.org/schema.json"

  Scenario: Enter multiple URLs for validation
    When I go to the homepage
    And I enter the following urls:
      |http://example.org/test.csv|
      |http://example.org/test2.csv|
      |http://example.org/test3.csv|
      |http://example.org/test4.csv|
    Then a Pusher notification should be sent
    When I press "Validate"
    # We have to do this because I can't get Pusher to work with PhantomJS
    When the CSV has finished processing
    And I access my page of validation results
    And I should see "http://example.org/test.csv"
    And I should see "http://example.org/test2.csv"
    And I should see "http://example.org/test3.csv"
    And I should see "http://example.org/test4.csv"

  Scenario: Enter multiple URLs with a schema URL
    When I go to the homepage
    And I enter the following urls:
      |http://example.org/test.csv|
      |http://example.org/test2.csv|
      |http://example.org/test3.csv|
      |http://example.org/test4.csv|
    And I check the "schema" checkbox
    And I enter "http://example.org/schema.json" in the "schema_url" field
    Then a Pusher notification should be sent
    When I press "Validate"
    # We have to do this because I can't get Pusher to work with PhantomJS
    When the CSV has finished processing
    And I access my page of validation results
    And the package validations should have the correct schema
