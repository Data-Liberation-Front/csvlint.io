require 'spec_helper'

describe ApplicationController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end

    it "returns 303 redirect if validation is in DB" do
      validation = FactoryGirl.create :validation, url: "http://data.com/data.csv"
      get 'index', uri: "http://data.com/data.csv"
      expect(response).to be_redirect
      expect(response.code).to eq("303")
      expect(response.location).to eq("http://test.host/validation/#{validation.id}")
    end

    it "returns 202 if csv is not in DB" do
      get 'index', uri: "http://data.com/data.csv"
      expect(response.code).to eq("202")
    end

  end

end
