@data_expiry
Feature: Clean up old uploaded CSVs

  Scenario: uploaded CSV validations should have a TTL field as attribute
    Given I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Validate"
    Then there should be 1 validation
    And that validation should have an expirable field

