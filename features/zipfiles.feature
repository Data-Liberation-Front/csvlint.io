Feature: CSV Validation
  
  Scenario: Upload a multiple zipped CSVs for validation
    When I go to the homepage
    And I attach the file "csvs/multiple_files.zip" to the "file" field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "valid.csv"
    And I should see "warnings.csv"
    And I should see "revalidate.csv"
    And my datapackage should be persisited in the database
  