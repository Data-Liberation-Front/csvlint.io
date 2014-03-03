@vcr
Feature: Load from CKAN repositories

  Scenario: Load a single CSV from a CKAN url
    When I go to the homepage
    And I enter the CKAN repository "http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report" in the url field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "We've noticed that you have submitted a URL that refers to a CKAN dataset."
    And I should see "https://www.gov.uk/government/publications/disposal-database-house-of-commons-report"
    And my datapackage should be persisited in the database

  Scenario: Ignore non-csv resources
    When I go to the homepage
    And I enter the CKAN repository "http://data.gov.uk/dataset/index-of-multiple-deprivation" in the url field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "We've noticed that you have submitted a URL that refers to a CKAN dataset."
    And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/15240/1871702.csv"
    And my datapackage should be persisited in the database