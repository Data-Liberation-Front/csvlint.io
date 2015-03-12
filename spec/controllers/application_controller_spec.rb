require 'spec_helper'

describe ApplicationController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "returns 303 redirect if validation is in DB" do
      validation = FactoryGirl.create :validation, url: "http://data.com/data.csv"
      get 'index', uri: "http://data.com/data.csv"
      response.should be_redirect
      response.code.should == "303"
      response.location.should == "http://test.host/validation/#{validation.id}"
    end

    it "returns 202 if csv is not in DB" do
      get 'index', uri: "http://data.com/data.csv"
      response.code.should == "202"
    end

  end

end
