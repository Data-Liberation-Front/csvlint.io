require 'spec_helper'

describe ValidationController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'validate'" do

    it "redirects to root if no URL is supplied" do
      get 'validate'
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if an invalid url is supplied" do
      get 'validate', url: 'complete@balls:/'
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if a relative url is supplied" do
      get 'validate', url: '/test.csv'
      response.should be_redirect
      response.location.should == root_url
    end

    it "redirects to root if a non-http[s] url is supplied" do
      get 'validate', url: 'file://test.csv'
      response.should be_redirect
      response.location.should == root_url
    end

    it "returns http success if a sensible url is supplied" do
      mock_csv("http://example.com/test.csv", 'csvs/valid.csv')
      get 'validate', url: 'http://example.com/test.csv'
      response.should be_success
    end

  end

  describe "GET 'validate' HTML" do
    
    it "has no warnings or errors for valid CSV" do
      mock_csv("http://example.com/test.csv", 'csvs/valid.csv')
      get 'validate', url: 'http://example.com/test.csv'
      response.should be_success
      assigns(:warnings).should be_empty
      assigns(:errors).should be_empty
    end
    
    it "has warnings or errors for warning CSV" do
      mock_csv("http://example.com/test.csv", 'csvs/warnings.csv')
      get 'validate', url: 'http://example.com/test.csv'
      response.should be_success
      assigns(:warnings).should_not be_empty
      assigns(:errors).should be_empty
    end
    
    it "has errors for error CSV" do
      mock_csv("http://example.com/test.csv", 'csvs/errors.csv')
      get 'validate', url: 'http://example.com/test.csv'
      response.should be_success
      assigns(:errors).should_not be_empty
    end
    
  end

  describe "GET 'validate' PNG" do

    it "returns valid image for a good CSV" do
      mock_csv("http://example.com/test.csv", 'csvs/valid.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :png
      response.should be_success
      response.body.length.should == 1588
    end

    it "returns invalid image for a CSV with errors" do
      mock_csv("http://example.com/test.csv", 'csvs/errors.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :png
      response.should be_success
      response.body.length.should == 1760
    end

    it "returns warning image for a CSV with warnings" do
      mock_csv("http://example.com/test.csv", 'csvs/warnings.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :png
      response.should be_success
      response.body.length.should == 2099
    end

  end

  describe "GET 'validate' SVG" do

    it "returns valid image for a good CSV" do
      mock_csv("http://example.com/test.csv", 'csvs/valid.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :svg
      response.should be_success
      response.body.should include(">valid<")
    end

    it "returns invalid image for a CSV with errors" do
      mock_csv("http://example.com/test.csv", 'csvs/errors.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :svg
      response.should be_success
      response.body.should include(">invalid<")
    end

    it "returns warning image for a CSV with warnings" do
      mock_csv("http://example.com/test.csv", 'csvs/warnings.csv')
      get 'validate', url: 'http://example.com/test.csv', format: :svg
      response.should be_success
      response.body.should include(">warnings<")
    end

  end

end
