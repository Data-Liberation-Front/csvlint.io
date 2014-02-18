Feature: Sceham Validation
  In order to make sure my CSV files are usable by others
  As a data publisher
  I want to make sure that my CSV files are valid with respect to a schema
  
  Background:
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/test.csv"
    Given the fixture "csvs/info.csv" is available at the URL "http://example.org/info.csv"
    Given the fixture "schemas/valid.json" is available at the URL "http://example.org/schema.json"
    Given the fixture "schemas/invalid.json" is available at the URL "http://example.org/bad_schema.json"
    
  Scenario: Enter a URL and a schema URL for validation
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see my URL
    And I should see my schema URL

  Scenario: Bad schema
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/bad_schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "Invalid schema"

  Scenario: Don't show schema error if no schema specified
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should not see "Invalid schema"

  Scenario: Upload a file and a schema for validation
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I attach the file "schemas/valid.json" to the "schema_file" field
    And I press "Upload and validate"
    Then I should see a page of validation results
  
  Scenario: List schemas
    Given there are 30 schemas in the database
    And I visit the schema list page
    Then I should see 25 schemas listed
    And I should see a paginator
    
  Scenario: Store schema information when validating
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
    And I enter "http://example.org/schema.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I visit the schema list page
    Then I should see "http://example.org/schema.json"
    
  Scenario: Share schemas between validations
    When I go to the homepage
    And I enter "http://example.org/test.csv" in the "url" field
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
    And I attach the file "schemas/valid.json" to the "schema_file" field
    And I press "Upload and validate"
    Then I should see a page of validation results
    And I visit the schema list page
    Then I should see 0 schemas listed
  
  Scenario: Don't store invalid schemas
    When I go to the homepage
    And I attach the file "csvs/valid.csv" to the "file" field
    And I attach the file "schemas/invalid.json" to the "schema_file" field
    And I press "Upload and validate"
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
    And I should see "Required: true"
  
  Scenario: Show schema validation failure messages
    Given the fixture "csvs/all_constraints.csv" is available at the URL "http://example.org/all_constraints.csv"
    Given the fixture "schemas/all_constraints.json" is available at the URL "http://example.org/all_constraints.json"
    When I go to the homepage
    And I enter "http://example.org/all_constraints.csv" in the "url" field
    And I enter "http://example.org/all_constraints.json" in the "schema_url" field
    And I press "Validate"
    Then I should see a page of validation results
    And I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>[A-Za-z0-9_]*</code>. Your value, <code>derp-derp</code>, does not."
    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
    And I should see "According to the schema, we expected to see the column <code>Email</code>, but it wasn't there."
    And I should see "We did not expect to see the column <code>URL</code>, given the schema you used."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be between 13 and 99 inclusive. <code>4</code> is out of range."
    And I should see "Values in the <code>Age</code> column must be between 13 and 99 inclusive. <code>103</code> is out of range."