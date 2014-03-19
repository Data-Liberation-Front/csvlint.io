require 'spec_helper'

describe ValidationController do

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
  
  describe "POST 'update'" do
    
    it "updates a CSV sucessfully" do
       mock_file("http://example.com/test.csv", 'csvs/valid.csv')
       post 'create', urls: ['http://example.com/test.csv']
       Validation.any_instance.should_receive(:update_attributes).once
       put 'update', id: Validation.first.id
       response.should be_redirect
    end
    
    it "updates a CSV with a new schema sucessfully" do
       mock_file("http://example.com/revalidate.csv", 'csvs/revalidate.csv')
       post 'create', urls: ['http://example.com/revalidate.csv']
       
       params = {
         :id => Validation.first.id,
         :header => "true",
         :delimiter => ";",
         :skip_initial_space => "true",
         :line_terminator => "\\n",
         :quote_char => "'"
       }
       
       put 'update', params

       validator = Marshal.load Validation.first.result
       validator.warnings.select { |warning| warning.type == :check_options }.count.should == 0
              
       response.should be_redirect
    end
    
  end

  describe "GET 'show' PNG" do
  
    it "returns valid image for a good CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 1588
    end
  
    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 1760
    end
  
    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 2099
    end
  
  end
  
  describe "GET 'show' SVG" do
  
    it "returns valid image for a good CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">valid<")
    end
  
    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">invalid<")
    end
  
    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">warnings<")
    end
    
    it "queues another check when the image is loaded" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      post 'create', urls: ['http://example.com/test.csv']
      validation = Validation.first
      Validation.any_instance.should_receive(:delay).and_call_original
      get 'show', id: validation.id, format: :svg
      Delayed::Job.count.should == 1
    end
  
  end

end
