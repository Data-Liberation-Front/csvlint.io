Feature: Schema Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid with respect to a schema
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "schemas/valid.json" is available at the URL "http://example.org/schema.json"
    Given the fixture "schemas/invalid.json" is available at the URL "http://example.org/empty_schema.json"
    Given the fixture "schemas/malformed.json" is available at the URL "http://example.org/malformed.json"
    Given the fixture "csvs/all_constraints.csv" is available at the URL "http://example.org/all_constraints.csv"
    Given the fixture "schemas/all_constraints.json" is available at the URL "http://example.org/all_constraints.json"
    
  Scenario: Enter a URL and a schema URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And I should see my schema URL
  
  Scenario: Enter a URL and a schema URL for validation without checking the schema checkbox
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And I should not see my schema URL

  Scenario: empty schema
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/empty_schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Empty Schema"

  Scenario: Malformed Schema from URLs
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/malformed.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Malformed Schema"

  Scenario: Malformed Schema from file upload
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/malformed.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Malformed Schema"


  Scenario: Don't show schema error if no schema specified
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should not see "Invalid schema"

  Scenario: Upload a file and a valid schema for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/valid.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results

  Scenario: Upload a file and an invalid schema for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/invalid.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results

  Scenario: Upload a file and a Malformed Schema for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/malformed.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Malformed Schema"

  Scenario: Upload a file and a schema URL for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results

  Scenario: Enter a URL and upload a schema for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I attach the file "schemas/valid.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
  
  Scenario: List schemas
    Given there are 30 schemas in the database
    And I visit the schema list page
    Then I should see 25 schemas listed
    And I should see a paginator
    
  Scenario: Store schema information when validating
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I visit the schema list page
    Then I should see "http://example.org/schema.json"
    
  Scenario: Share schemas between validations
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    And I go to the homepage
    And I enter "http://example.org/info.csv" in the "url" field
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    And I visit the schema list page
    Then I should see 1 schema listed
    Then I should see "http://example.org/schema.json"
    
  Scenario: Don't store uploaded schemas
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/valid.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I visit the schema list page
    Then I should see 0 schemas listed
  
  Scenario: Don't store invalid schemas
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/invalid.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I visit the schema list page
    Then I should see 0 schemas listed

  Scenario: Schema details page
    Given "http://example.org/schema.json" has been previously used for validation 
    And I visit the schema list page
    And I click on "http://example.org/schema.json"
    Then I should see a schema details page
    And I should see 3 fields
    And I should see "http://example.org/schema.json"
    And I should see "FirstName"
  
  Scenario: Example CSV download
    Given "http://example.org/schema.json" has been previously used for validation 
    And I visit the schema list page
    And I click on "http://example.org/schema.json"
    Then I should see a schema details page
    When I click on "Download Example CSV File"
    Then a CSV file should be downloaded
    And that CSV file should have a field "FirstName"
    And that CSV file should have a field "LastName"
    And that CSV file should have a field "Insult"
    And that CSV file should have double-quoted fields
    And that CSV file should use CRLF line endings



  Scenario: Show schema validation failure messages via URL
    Given the fixture "csvs/all_constraints.csv" is available at the URL "http://example.org/all_constraints.csv"
    Given the fixture "schemas/all_constraints.json" is available at the URL "http://example.org/all_constraints.json"
    When I go to the homepage
    And I enter "http://example.org/all_constraints.csv" in the "url" field
    And I check the "schema" checkbox
    And I enter "http://example.org/all_constraints.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>^[A-Za-z0-9_]*$</code>. Your value, <code>derp-derp</code>, does not."
#    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
#    breaks here
    And I should see "There was an unexpected column on row <code>6</code>. Make sure that none of the fields contain commas, are correctly quoted, etc."
    And I should see "There was a missing column on row <code>7</code>. Make sure this row includes all the data that should be there."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be 13 or above. <code>4</code> is too low."
    And I should see "Values in the <code>Age</code> column must be 99 or below. <code>103</code> is too high."
    And I should see "Values in the <code>Height</code> column must be 20 or above. <code>13</code> is too low."
    And I should see "Values in the <code>Weight</code> column must be 500 or below. <code>600</code> is too high."

  Scenario: Show schema validation failure messages via file upload
    When I go to the homepage
    And I attach the file "csvs/all_constraints.csv" to the "file" field
    And I check the "schema" checkbox
    And I attach the file "schemas/all_constraints.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>^[A-Za-z0-9_]*$</code>. Your value, <code>derp-derp</code>, does not."
#    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
    And I should see "There was an unexpected column on row <code>6</code>. Make sure that none of the fields contain commas, are correctly quoted, etc."
    And I should see "There was a missing column on row <code>7</code>. Make sure this row includes all the data that should be there."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be 13 or above. <code>4</code> is too low."
    And I should see "Values in the <code>Age</code> column must be 99 or below. <code>103</code> is too high."
    And I should see "Values in the <code>Height</code> column must be 20 or above. <code>13</code> is too low."
    And I should see "Values in the <code>Weight</code> column must be 500 or below. <code>600</code> is too high."

  Scenario: Show schema validation failure messages via URL for CSV and upload for schema
    When I go to the homepage
    And I enter "http://example.org/all_constraints.csv" in the "url" field
    And I check the "schema" checkbox
    And I attach the file "schemas/all_constraints.json" to the "schema_file" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>^[A-Za-z0-9_]*$</code>. Your value, <code>derp-derp</code>, does not."
#    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
    And I should see "There was an unexpected column on row <code>6</code>. Make sure that none of the fields contain commas, are correctly quoted, etc."
    And I should see "There was a missing column on row <code>7</code>. Make sure this row includes all the data that should be there."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be 13 or above. <code>4</code> is too low."
    And I should see "Values in the <code>Age</code> column must be 99 or below. <code>103</code> is too high."
    And I should see "Values in the <code>Height</code> column must be 20 or above. <code>13</code> is too low."
    And I should see "Values in the <code>Weight</code> column must be 500 or below. <code>600</code> is too high."

  Scenario: Show schema validation failure messages via file upload for CSV and URL for schema
    When I go to the homepage
    And I attach the file "csvs/all_constraints.csv" to the "file" field
    And I check the "schema" checkbox
    And I enter "http://example.org/all_constraints.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>^[A-Za-z0-9_]*$</code>. Your value, <code>derp-derp</code>, does not."
#    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
    And I should see "There was an unexpected column on row <code>6</code>. Make sure that none of the fields contain commas, are correctly quoted, etc."
    And I should see "There was a missing column on row <code>7</code>. Make sure this row includes all the data that should be there."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be 13 or above. <code>4</code> is too low."
    And I should see "Values in the <code>Age</code> column must be 99 or below. <code>103</code> is too high."
    And I should see "Values in the <code>Height</code> column must be 20 or above. <code>13</code> is too low."
    And I should see "Values in the <code>Weight</code> column must be 500 or below. <code>600</code> is too high."