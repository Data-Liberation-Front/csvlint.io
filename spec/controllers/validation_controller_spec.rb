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
      get 'validate', url: 'http://example.com/test.csv'
      response.should be_success
    end

  end

end
