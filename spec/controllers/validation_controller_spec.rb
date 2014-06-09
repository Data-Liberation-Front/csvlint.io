require 'spec_helper'

describe ValidationController do

  describe "POST 'update'" do

    it "updates a CSV sucessfully" do
       mock_file("http://example.com/test.csv", 'csvs/valid.csv')
       Validation.create_validation('http://example.com/test.csv')
       put 'update', id: Validation.first.id
       response.should be_redirect
    end

    it "updates a CSV with a new schema sucessfully" do
       mock_file("http://example.com/revalidate.csv", 'csvs/revalidate.csv')
       Validation.create_validation('http://example.com/revalidate.csv')

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
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 1588
    end

    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 1760
    end

    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      response.should be_success
      response.body.length.should == 2099
    end

  end

  describe "GET 'show' SVG" do

    it "returns valid image for a good CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">valid<")
    end

    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">invalid<")
    end

    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      response.should be_success
      response.body.should include(">warnings<")
    end

    it "doesn't revalidate for images" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      validation.should_not_receive(:check_validation)
      get 'show', id: validation.id, format: :svg
    end

  end

end
