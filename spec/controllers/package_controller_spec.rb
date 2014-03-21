require 'spec_helper'

describe PackageController do
  
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
       response.location.should == package_url(package)
    end
    
    it "supports multiple files" do
      post 'create', files: [
                        mock_upload('csvs/valid.csv'),
                        mock_upload('csvs/valid.csv'),
                        mock_upload('csvs/valid.csv')
                      ]                
      response.should be_redirect
      package = Package.first
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
                        mock_upload('csvs/valid.zip', 'application/zip'),
                        mock_upload('csvs/multiple_files.zip', 'application/zip'),
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
