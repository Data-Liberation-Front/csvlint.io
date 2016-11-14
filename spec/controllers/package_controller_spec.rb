require 'spec_helper'

describe PackageController, type: :controller do

  describe "POST 'create'" do

    it "redirects to root if no URL is supplied" do
      post 'create'
      expect(response).to be_redirect
      expect(response.location).to eq(root_url)
    end

    it "redirects to root if an invalid url is supplied" do
      post 'create', urls: ['complete@balls:/']
      expect(response).to be_redirect
      expect(response.location).to eq(root_url)
    end

    it "redirects to root if a relative url is supplied" do
      post 'create', urls: ['/test.csv']
      expect(response).to be_redirect
      expect(response.location).to eq(root_url)
    end

    it "redirects to root if a non-http[s] url is supplied" do
      post 'create', urls: ['file://test.csv']
      expect(response).to be_redirect
      expect(response.location).to eq(root_url)
    end

    it "creates a validation and redirects if a sensible url is supplied" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      expect(response).to be_redirect
      validation = Validation.first
      expect(response.location).to eq(validation_url(validation))
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
       expect(response).to be_redirect
       package = Package.first
       expect(package.validations.count).to eq(3)
       expect(response.location).to eq(package_url(package))
    end

    it "supports multiple files" do
      post 'create', file_ids: [
                        mock_upload('valid.csv'),
                        mock_upload('valid.csv'),
                        mock_upload('valid.csv')
                      ]
      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(3)
      expect(response.location).to eq(package_url(package))
    end

    it "supports multiple zip urls" do
       mock_file("http://example.com/valid.zip", 'csvs/valid.zip')
       mock_file("http://example.com/multiple_files.zip", 'csvs/multiple_files.zip')
       post 'create', urls: [
                              'http://example.com/valid.zip',
                              'http://example.com/multiple_files.zip',
                            ]
       expect(response).to be_redirect
       package = Package.first
       expect(package.validations.count).to eq(4)
       expect(response.location).to eq(package_url(package))
    end

    it "supports multiple zip files" do
      post 'create', file_ids: [
                        mock_upload('valid.zip'),
                        mock_upload('multiple_files.zip'),
                      ]
      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(4)
      expect(response.location).to eq(package_url(package))
    end

    it "supports data URLs" do
      post 'create', files_data: [
                            create_data_uri('csvs/valid.csv')
                          ]

      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(1)
      expect(response.location).to eq(validation_url(package.validations.first))
    end

    it "supports multiple data URLs" do
      post 'create', files_data: [
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv'),
                            create_data_uri('csvs/valid.csv')
                          ]

      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(4)
      expect(response.location).to eq(package_url(package))
    end

    it "supports single zip files as data URLs" do
      post 'create', files_data: [
                        create_data_uri('csvs/valid.zip', 'application/zip'),
                      ]
      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(1)
      expect(response.location).to eq(validation_url(package.validations.first))
    end

    it "supports multiple zip files as data URLs" do
      post 'create', files_data: [
                        create_data_uri('csvs/valid.zip', 'application/zip'),
                        create_data_uri('csvs/multiple_files.zip', 'application/zip'),
                      ]
      expect(response).to be_redirect
      package = Package.first
      expect(package.validations.count).to eq(4)
      expect(response.location).to eq(package_url(package))
    end

    it "supports schema uploads as data URLs" do
      mock_file("http://example.com/test.csv", 'csvs/all_constraints.csv')
      post 'create', urls: [
                             'http://example.com/test.csv',
                           ],
                     schema: "1",
                     schema_data: create_data_uri('schemas/all_constraints.json', 'application/json')
      # above accurately emulates how the file upload works by a user
      expect(response).to be_redirect
      package = Package.first
      validation = package.validations.first
      validator = validation.validator
      expect(response.location).to eq(validation_url(validation))
      # byebug
      expect(validator.errors.count).to eq(10)
      # the above is breaking at present
      expect(validator.errors[0].type).to eq(:missing_value)
      expect(validator.errors[1].type).to eq(:min_length)
      expect(validator.errors[2].type).to eq(:min_length)
      expect(validator.errors[3].type).to eq(:max_length)
      expect(validator.errors[4].type).to eq(:pattern)
      expect(validator.errors[5].type).to eq(:unique)
      expect(validator.errors[6].type).to eq(:below_minimum)
      expect(validator.errors[7].type).to eq(:above_maximum)
      expect(validator.errors[8].type).to eq(:above_maximum)
      expect(validator.errors[9].type).to eq(:below_minimum)
    end

  end

  describe "POST 'create' HTML" do

    it "has no warnings or errors for valid CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      expect(response).to be_redirect
      validation = Marshal.load(Validation.first.result)
      expect(validation.warnings).to be_empty
      expect(validation.errors).to be_empty
    end

    it "has warnings or errors for warning CSV" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      post 'create', urls: ['http://example.com/test.csv']
      expect(response).to be_redirect
      validation = Marshal.load(Validation.first.result)
      expect(validation.warnings).not_to be_empty
      expect(validation.errors).to be_empty
    end

    it "has errors for error CSV" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      post 'create', urls: ['http://example.com/test.csv']
      expect(response).to be_redirect
      validation = Marshal.load(Validation.first.result)
      expect(validation.errors).not_to be_empty
    end

  end

end
