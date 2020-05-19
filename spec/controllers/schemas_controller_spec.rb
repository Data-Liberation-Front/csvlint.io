require 'spec_helper'

describe SchemasController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'index' with uri arg" do

    it "returns 303 redirect if schema is in DB" do
      schema = FactoryBot.create :schema, url: "http://data.com/schema.json"
      get 'index', uri: "http://data.com/schema.json"
      expect(response).to be_redirect
      expect(response.code).to eq("303")
      expect(response.location).to eq("http://test.host/schemas/#{schema.id}")
    end

    it "returns 404 if schema is not in DB" do
      get 'index', uri: "http://data.com/schema.json"
      expect(response).to be_not_found
    end

  end

end
