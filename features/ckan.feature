@vcr
Feature: Load from CKAN repositories

  Scenario: Load a single CSV from a CKAN url
    When I go to the homepage
    And I enter the CKAN repository "http://data.gov.uk/dataset/defence-infrastructure-organisation-disposals-database-house-of-commons-report" in the url field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "We've noticed that you have submitted a URL that refers to a CKAN dataset."
    And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/253423/20131025_HoC_report_Oct_2013.csv"
    And my datapackage should be persisited in the database

  Scenario: Ignore non-csv resources
    When I go to the homepage
    And I enter the CKAN repository "http://data.gov.uk/dataset/uk-civil-service-high-earners" in the url field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "We've noticed that you have submitted a URL that refers to a CKAN dataset."
    And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/61944/ndpb-high-earners.csv"
    And I should not see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/60516/150k-decision-notice.pdf"
    And my datapackage should be persisited in the database

  Scenario: Load multiple CSVs from a CKAN url
  When I go to the homepage
  And I enter the CKAN repository "http://data.gov.uk/dataset/uk-civil-service-high-earners" in the url field
  And I press "Validate"
  Then I should be redirected to my package page
  And I should see "We've noticed that you have submitted a URL that refers to a CKAN dataset."
  And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/61944/ndpb-high-earners.csv"
  And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/62342/high-earners-pay-2011.csv"
  And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/83716/high-earners-pay-2012.csv"
  And I should see "https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/62343/high-earners-pay_0.csv"
