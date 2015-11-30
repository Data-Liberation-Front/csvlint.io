@timecop
Feature: Clean up old uploaded CSVs

  Scenario: Delete CSV after 24 hours
    Given I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Validate"
    And 25 hours have passed
    When we clean up old files
    Then there should be 1 validation
    And that validation should not contain a file
    And there should be 0 stored files in GridFs
    And there should be 0 stored chunks in GridFs

  Scenario: CSV not deleted after recent validation
    Given I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Validate"
    When we clean up old files
    Then there should be 1 validation
    And that validation should contain a file
    And there should be 1 stored files in GridFs
    And there should be 1 stored chunks in GridFs

  Scenario: Clean up job is requeued
    When we clean up old files
    Then the clean up task should have been requeued

  Scenario: Job is requeued even if we hit an exception
    Given the clean up job causes an error
    When we clean up old files
    Then the clean up task should have been requeued
