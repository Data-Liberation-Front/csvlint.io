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

    before(:each) do
      @connection = double(CloudFlare::Connection)

      allow(CloudFlare::Connection).to receive(:new) {
        allow(@connection).to receive(:zone_file_purge)
        @connection
      }
    end

    it "updates a CSV sucessfully" do
       mock_file("http://example.com/test.csv", 'csvs/valid.csv')
       Validation.create_validation('http://example.com/test.csv')
       put 'update', id: Validation.first.id
       expect(response).to be_redirect
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
       expect(validator.warnings.select { |warning| warning.type == :check_options }.count).to eq(0)

       expect(response).to be_redirect
    end

    it 'purges the cache when updating' do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      expect(@connection).to receive(:zone_file_purge).with('csvlint.io', validation_url(Validation.first))
      put 'update', id: Validation.first.id
    end

  end

  describe "GET 'show' PNG" do

    it "returns valid image for a good CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      expect(response).to be_success
      expect(response.body.length).to eq(1588)
    end

    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      expect(response).to be_success
      expect(response.body.length).to eq(1760)
    end

    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :png
      expect(response).to be_success
      expect(response.body.length).to eq(2099)
    end

  end

  describe "GET 'show' SVG" do

    it "returns valid image for a good CSV" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      expect(response).to be_success
      expect(response.body).to include(">valid<")
    end

    it "returns invalid image for a CSV with errors" do
      mock_file("http://example.com/test.csv", 'csvs/errors.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      expect(response).to be_success
      expect(response.body).to include(">invalid<")
    end

    it "returns warning image for a CSV with warnings" do
      mock_file("http://example.com/test.csv", 'csvs/warnings.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      get 'show', id: validation.id, format: :svg
      expect(response).to be_success
      expect(response.body).to include(">warnings<")
    end

    it "queues another check when the image is loaded" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      expect {
        get 'show', id: validation.id, format: :svg
      }.to change(Sidekiq::Extensions::DelayedClass.jobs, :size).by(1)
    end

    it "doesn't queue another check when the image is loaded if revalidate is false" do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      Validation.create_validation('http://example.com/test.csv')
      validation = Validation.first
      expect(Validation).to_not receive(:delay)
      expect {
        get 'show', id: validation.id, format: :svg, revalidate: false
      }.to change(Sidekiq::Extensions::DelayedClass.jobs, :size).by(0)
    end

  end

end
