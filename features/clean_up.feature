@timecop
Feature: Clean up old uploaded CSVs

  Scenario: Clean up job is requeued
    When we clean up old files
    Then the clean up task should have been requeued

  Scenario: Job is requeued even if we hit an exception
    Given the clean up job causes an error
    When we clean up old files
    Then the clean up task should have been requeued
