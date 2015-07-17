Feature: CSV Validation Loop
  In order to debug when the dialect validation loop should terminate
  I will test the sequences in which dialects can be amended

  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "csvs/errors.csv" is available at the URL "http://example.org/errors.csv"
    Given the fixture "csvs/revalidate.csv" is available at the URL "http://example.org/revalidate.csv"

  Scenario: Revalidate file using new options
#    the revalidate.csv will pass immediately on entry of colon separated field delimiter
  When I go to the homepage
  And I attach the file "csvs/revalidate.csv" to the "file" field
  And I press "Validate"
  And I enter ";" in the "Field delimiter" field
  And I enter "'" in the "Quote character" field
  And I select "LF (\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  Then I should see a page of validation results
  And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
  And I should not see "Check CSV parsing options"
  And I should see "Non standard dialect"

  Scenario: Revalidate file using new dialect options in sequence 'line terminator',then 'field delimiter'
  #  should fail due to URI error OR more specific  "no implicit conversion of nil into String (TypeError)"
  When I go to the homepage
  And I attach the file "csvs/revalidate.csv" to the "file" field
  And I press "Validate"
  And I select "LF (\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  And I enter ";" in the "Field delimiter" field
  And I press "Revalidate"
#    should fail here, i.e. when run via cucumber (mirrors the behaviour onsite), with byebug in controller or in gem
#    when byebug is in the controller csv_id is not set in the Validation object
  Then I should see a page of validation results
  And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
  And I should not see "Check CSV parsing options"
#    fails here when byebug in validation model
  And I should see "Non standard dialect"

  Scenario: Revalidate file using incompatible Line Breaks character
    When I go to the homepage
    And I attach the file "csvs/revalidate.csv" to the "file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I select "CRLF (\r\n)" from the "Line terminator" dropdown
    And I press "Revalidate"
    Then I should see a page of validation results
    And the database record should have a "warning" of the type "check_options"
    And I should not see "<strong>Congratulations!</strong> Your CSV is valid!"

  Scenario: Revalidate file using new dialect options in sequence 'field delimiter' then 'line terminator'
  #  should fail because the validation passes when field delimiter amended
  When I go to the homepage
  And I attach the file "csvs/revalidate.csv" to the "file" field
  And I press "Validate"
  And I enter ";" in the "Field delimiter" field
  And I press "Revalidate"
  And I select "LF (\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  Then I should see a page of validation results
  And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
  And I should not see "Check CSV parsing options"
  And I should see "Non standard dialect"

  Scenario: Revalidate file using new dialect options in sequence 'field delimiter' twice
  #  should fail due to bad URI message
  When I go to the homepage
  And I attach the file "csvs/revalidate.csv" to the "file" field
  And I press "Validate"
  And I select "LF (\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  And I select "CRLF (\r\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  Then I should see a page of validation results
  And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
  And I should not see "Check CSV parsing options"
  And I should see "Non standard dialect"

  Scenario: Revalidate file using new dialect options that dont match CSV
      #  should fail due to not finding drop down
  When I go to the homepage
  And I attach the file "csvs/revalidate.csv" to the "file" field
  And I press "Validate"
  And I select "CRLF (\r\n)" from the "Line terminator" dropdown
  And I press "Revalidate"
  Then I should see a page of validation results
  And I should see "<strong>Congratulations!</strong> Your CSV is valid!"
  And I should not see "Check CSV parsing options"
  And I should see "Non standard dialect"