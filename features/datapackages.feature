Feature: Load from datapackage

  Background:
    Given the fixture "datapackages/single-datapackage.json" is available at the URL "http://example.org/single-datapackage.json" 
    Given the fixture "datapackages/multiple-datapackage.json" is available at the URL "http://example.org/multiple-datapackage.json" 
    Given the fixture "datapackages/datapackage-with-schema.json" is available at the URL "http://example.org/schema-datapackage.json" 
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/valid.csv"
    Given the fixture "csvs/valid.csv" is available at the URL "http://example.org/valid2.csv"
    Given the fixture "csvs/all_constraints.csv" is available at the URL "http://example.org/all_constraints.csv"
  
  Scenario: Load a single CSV from a datapackage url
    When I go to the homepage
    And I enter "http://example.org/single-datapackage.json" in the "url" field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "http://example.org/valid.csv"
    And my datapackage should be persisited in the database
    
  Scenario: Load multiple CSVs from a datapackage url
    When I go to the homepage
    And I enter "http://example.org/multiple-datapackage.json" in the "url" field
    And I press "Validate"
    Then I should be redirected to my package page
    And I should see "http://example.org/valid.csv"
    And I should see "http://example.org/valid2.csv"
    And my datapackage should be persisited in the database
    
  Scenario: Load schema from a datapackage url
    When I go to the homepage
    And I enter "http://example.org/schema-datapackage.json" in the "url" field
    And I press "Validate"
    Then I should be redirected to my package page
    When I click on the first report link
    Then I should see "The schema says that a value must be provided in the <code>Username</code> column. Make sure this column has values in all the rows."
    And I should see "The schema says that <code>Username</code> must be at least 5 characters long. Your value, <code>derp</code>, is not long enough."
    And I should see "The schema says that <code>Username</code> must be at most 10 characters long. Your value, <code>derpderpington</code>, is too long."
    And I should see "The schema says that values in <code>Username</code> must match <code>^[A-Za-z0-9_]*$</code>. Your value, <code>derp-derp</code>, does not."
    And I should see "We expected to see the header <code>Password</code>, but got <code>Secret</code>."
    And I should see "There was an unexpected column on row <code>6</code>. Make sure that none of the fields contain commas, are correctly quoted, etc."
    And I should see "There was a missing column on row <code>7</code>. Make sure this row includes all the data that should be there."
    And I should see "Values in the <code>Username</code> column must be unique. <code>derpina</code> has been used at least twice."
    And I should see "Values in the <code>Age</code> column must be 13 or above. <code>4</code> is too low."
    And I should see "Values in the <code>Age</code> column must be 99 or below. <code>103</code> is too high."
    And I should see "Values in the <code>Height</code> column must be 20 or above. <code>13</code> is too low."
    And I should see "Values in the <code>Weight</code> column must be 500 or below. <code>600</code> is too high."