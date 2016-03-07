require 'spec_helper'

describe ValidationController, type: :controller do

  describe "GET 'index'" do

    it 'generates a CSV of all validations with a url' do
      [
        "valid",
        "warnings",
        "invalid",
        "not_found",
      ].each_with_index do |state, i|
        (i + 1).times { |i| FactoryGirl.create :validation, url: "http://data.com/data#{i}.csv", state: state }
      end

      5.times { FactoryGirl.create :validation, url: nil }

      get 'index', format: "csv"

      expect(response.content_type).to eq('text/csv; charset=utf-8; header=present')

      csv = CSV.parse(response.body)
      expect(csv.count).to eq(11)
    end

  end

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

    it "queues another check when the image is loaded" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      Validation.any_instance.should_receive(:delay).and_call_original
      get 'show', id: validation.id, format: :svg
      Delayed::Job.count.should == 1
    end

    it "doesn't queue another check when the image is loaded if revalidate is false" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      Validation.any_instance.should_not_receive(:delay)
      get 'show', id: validation.id, format: :svg, revalidate: false
      Delayed::Job.count.should == 0
    end

  end

end
