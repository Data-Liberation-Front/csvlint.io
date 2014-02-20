Feature: CSV Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
    Given the fixture "csvs/revalidate.csv" is available at the URL "http://example.org/revalidate.csv"
    
  Scenario: Enter a URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And my url should be persisted in the database
    
  Scenario: Validation with info messages
    When I go to the homepage
    And I enter "http://example.org/info.csv" in the "url" field
    And I press "Validate"
    Then I should see "Non-standard Line Breaks"
    
  Scenario: Upload a file for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
  
  Scenario: Upload a file with warnings
    When I go to the homepage
    And I attach the file "csvs/warnings.csv" to the "file" field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
    And the database record should have a "warning" of the type "check_options"
    And I should see a page of validation results  

  Scenario: Upload a file with errors
    When I go to the homepage
    And I attach the file "csvs/errors.csv" to the "file" field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And my file should be persisted in the database
    And the database record should have a "error" of the type "ragged_rows"
    And I should see a page of validation results 
  
  Scenario: Find a CSV by url
    Given I have already validated the URL "http://example.org/test.csv"
    When I load the validation by URL
    Then I should see a page of validation results
    And I should see my URL 

  Scenario: Find a CSV badge by url
    Given I have already validated the URL "http://example.org/test.csv"
    When I load the validation badge by URL in "png" format
    Then I should get a badge in "png" format
    
  Scenario: List validations
    Given there are 30 validations in the database
    And I visit the list page
    Then I should see 25 validations listed
    And I should see a paginator
    
  Scenario: Latest validations only should be listed
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/list-test.csv"
    When I go to the homepage
    And I enter "http://example.org/list-test.csv" in the "url" field
    And I press "Validate"
    And the fixture "csvs/valid.csv" is available at the URL "http://example.org/list-test.csv"
    And I go to the homepage
    And I enter "http://example.org/list-test.csv" in the "url" field
    And I press "Validate"
    When I visit the list page
    Then my url should be displayed in the list
    And my url should have a link to the latest report next to it
  
  Scenario: Updated CSVs should be revalidated
    Given I have already validated the URL "http://example.org/test.csv"
    And it's two weeks in the future
    And I have updated the URL "http://example.org/test.csv"
    Then the validation should be updated
    When I load the validation by URL
    
  Scenario: Non-updated CSVs should not be revalidated
    Given I have already validated the URL "http://example.org/test.csv"
    And the CSV has not changed
    Then the validation should not be updated
    When I load the validation by URL
    
  Scenario: Give the option to revalidate if CSV is invalid
    When I go to the homepage
    And I enter "http://example.org/errors.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should be given the option to revalidate using a different dialect
    
  # Scenario: Revalidate CSV using new options
  #   When I go to the homepage
  #   And I enter "http://example.org/errors.csv" in the "url" field
  #   And I press "Validate"
  #   And I enter ";" in the "Field delimiter" field
  #   And I enter "'" in the "Quote character" field
  #   And I select "LF (\n)" from the "Line terminator" dropdown
  #   And I press "Revalidate"
  #   Then I should see a page of validation results
  #   And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
