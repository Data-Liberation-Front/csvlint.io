@data_expiry
Feature: Clean up old uploaded CSVs

  Scenario: uploaded CSV validations should have a TTL field as attribute
    Given I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Validate"
    Then there should be 1 validation
    And that validation should have an expirable field


#  Scenario: Uploaded CSV Validations should not persist after 24 hours
#    Given I go to the homepage
#    Then we travel back in time
#    And I attach the file "csvs/valid.csv" to the "file" field
#    And I press "Validate"
#    Then there should be 0 validation
#    And there should be 0 stored files in GridFs
#
#  Scenario: CSV Validations not deleted after recent validation
#    Given I go to the homepage
#    And I attach the file "csvs/valid.csv" to the "file" field
#    And I press "Validate"
#    When we clean up old files
#    Then there should be 1 validation
#    And that validation should contain a file
#    And there should be 1 stored files in GridFs
