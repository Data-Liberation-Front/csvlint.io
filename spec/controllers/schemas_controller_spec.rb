require 'spec_helper'

describe SchemasController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'index' with uri arg" do

    it "returns 303 redirect if schema is in DB" do
      schema = FactoryGirl.create :schema, url: "http://data.com/schema.json"
      get 'index', uri: "http://data.com/schema.json"
      response.should be_redirect
      response.code.should == "303"
      response.location.should == "http://test.host/schemas/#{schema.id}"
    end

    it "returns 404 if schema is not in DB" do
      get 'index', uri: "http://data.com/schema.json"
      response.should be_not_found
    end

  end

end
