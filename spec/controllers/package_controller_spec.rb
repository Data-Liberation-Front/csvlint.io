require 'spec_helper'

describe PackageController, type: :controller do

  describe "POST 'create'" do

    it "redirects to root if no URL is supplied" do
      post 'create'
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if an invalid url is supplied" do
      post 'create', urls: ['complete@balls:/']
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if a relative url is supplied" do
      post 'create', urls: ['/test.csv']
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if a non-http[s] url is supplied" do
      post 'create', urls: ['file://test.csv']
      response.should be_redirect
      response.location.should == root_url
    end

    it "creates a validation and redirects if a sensible url is supplied" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      response.should be_redirect
      validation = Validation.first
      response.location.should == validation_url(validation)
    end

    it "supports multiple urls" do
       mock_file("http://example.com/test.csv", 'csvs/valid.csv')
       mock_file("http://example.com/test2.csv", 'csvs/valid.csv')
       mock_file("http://example.com/test3.csv", 'csvs/valid.csv')
       post 'create', urls: [
                              'http://example.com/test.csv',
                              'http://example.com/test2.csv',
                              'http://example.com/test3.csv'
                            ]
       response.should be_redirect
       package = Package.first
       package.validations.count.should == 3
       response.location.should == package_url(package)
    end

    it "supports multiple files" do
      post 'create', files: [
                        mock_upload('valid.csv'),
                        mock_upload('valid.csv'),
                        mock_upload('valid.csv')
                      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 3
      response.location.should == package_url(package)
    end

    it "supports multiple zip urls" do
       mock_file("http://example.com/valid.zip", 'csvs/valid.zip')
       mock_file("http://example.com/multiple_files.zip", 'csvs/multiple_files.zip')
       post 'create', urls: [
                              'http://example.com/valid.zip',
                              'http://example.com/multiple_files.zip',
                            ]
       response.should be_redirect
       package = Package.first
       package.validations.count.should == 4
       response.location.should == package_url(package)
    end

    it "supports multiple zip files" do
      post 'create', files: [
                        mock_upload('valid.zip'),
                        mock_upload('multiple_files.zip'),
                      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 4
      response.location.should == package_url(package)
    end

    it "supports data URLs" do
      post 'create', files_data: [
                            create_data_uri('csvs/valid.csv')
                          ]

      response.should be_redirect
      package = Package.first
      package.validations.count.should == 1
      response.location.should == validation_url(package.validations.first)
    end

    it "supports multiple data URLs" do
      post 'create', files_data: [
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv')
                          ]

      response.should be_redirect
      package = Package.first
      package.validations.count.should == 4
      response.location.should == package_url(package)
    end

    it "supports single zip files as data URLs" do
      post 'create', files_data: [
                        create_data_uri('csvs/valid.zip', 'application/zip'),
                      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 1
      response.location.should == validation_url(package.validations.first)
    end

    it "supports multiple zip files as data URLs" do
      post 'create', files_data: [
                        create_data_uri('csvs/valid.zip', 'application/zip'),
                        create_data_uri('csvs/multiple_files.zip', 'application/zip'),
                      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 4
      response.location.should == package_url(package)
    end

    it "supports schema uploads as data URLs" do
      mock_file("http://example.com/test.csv", 'csvs/all_constraints.csv')
      post 'create', urls: [
                             'http://example.com/test.csv',
                           ],
                     schema: "1",
                     schema_data: create_data_uri('schemas/all_constraints.json', 'application/json')
      # above accurately emulates how the file upload works by a user
      response.should be_redirect
      package = Package.first
      validation = package.validations.first
      validator = validation.validator
      response.location.should == validation_url(validation)
      # byebug
      validator.errors.count.should == 10
      # the above is breaking at present
      validator.errors[0].type.should == :missing_value
      validator.errors[1].type.should == :min_length
      validator.errors[2].type.should == :min_length
      validator.errors[3].type.should == :max_length
      validator.errors[4].type.should == :pattern
      validator.errors[5].type.should == :unique
      validator.errors[6].type.should == :below_minimum
      validator.errors[7].type.should == :above_maximum
      validator.errors[8].type.should == :above_maximum
      validator.errors[9].type.should == :below_minimum
    end

    it "supports standard file uploads" do
      post 'create', standard_files: [
        mock_uploaded_file('csvs/valid.csv')
      ]
      response.should be_redirect
      validation = Validation.first
      response.location.should == validation_url(validation)
    end

    it "supports multiple standard file uploads" do
      post 'create', standard_files: [
        mock_uploaded_file('csvs/valid.csv'),
        mock_uploaded_file('csvs/valid.csv'),
        mock_uploaded_file('csvs/valid.csv')
      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 3
      response.location.should == package_url(package)
    end

    it "supports multiple standard upload zip files" do
      post 'create', standard_files: [
                        mock_uploaded_file('csvs/valid.zip'),
                        mock_uploaded_file('csvs/multiple_files.zip'),
                      ]
      response.should be_redirect
      package = Package.first
      package.validations.count.should == 4
      response.location.should == package_url(package)
    end

  end

  describe "POST 'create' HTML" do

    it "has no warnings or errors for valid CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      response.should be_redirect
      validation = Marshal.load(Validation.first.result)
      validation.warnings.should be_empty
      validation.errors.should be_empty
    end

    it "has warnings or errors for warning CSV" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      post 'create', urls: ['http://example.com/test.csv']
      response.should be_redirect
      validation = Marshal.load(Validation.first.result)
      validation.warnings.should_not be_empty
      validation.errors.should be_empty
    end

    it "has errors for error CSV" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      post 'create', urls: ['http://example.com/test.csv']
      response.should be_redirect
      validation = Marshal.load(Validation.first.result)
      validation.errors.should_not be_empty
    end

  end

end
