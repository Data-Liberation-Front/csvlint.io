require "spec_helper"

describe Legacy::Summary, type: :model do

  context "when generating summary" do
    before(:each) do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      validation = Legacy::Validation.create_validation("http://example.com/test.csv")

      mock_file("http://example.com/test2.csv", 'csvs/errors.csv')
      validation = Legacy::Validation.create_validation("http://example.com/test2.csv")

      mock_file("http://www.example.com/test3.csv", 'csvs/warnings.csv')
      validation = Legacy::Validation.create_validation("http://www.example.com/test3.csv")

      @summary = described_class.generate
    end

    it "should record number of valid sources" do
      expect(@summary.states["valid"]).to eq(1)
    end

    it "should record number of invalid sources" do
      expect(@summary.states["invalid"]).to eq(1)
    end

    it "should record number of not found sources" do
      expect(@summary.states["not_found"]).to eq(0)
    end

    it "should record number of sources with warnings" do
      expect(@summary.states["warnings"]).to eq(1)
    end

    it "should record number of unique sources" do
      expect(@summary.sources).to eq(3)
    end

    it "should record number of sources per host" do
      expect(@summary.hosts.keys.length).to eq(1)
      expect(@summary.hosts["example\uff0ecom"]).to eq(3)
    end

    it "should record occurences of errors" do
      expect(@summary.level_summary.errors_breakdown[:ragged_rows]).to eq(1)
      expect(@summary.level_summary.warnings_breakdown[:check_options]).to eq(1)
    end

    it "should count occurences across population of sources" do
      mock_file("http://example.com/test4.csv", 'csvs/multiple_errors.csv')
      validation = Legacy::Validation.create_validation("http://example.com/test4.csv")
      @summary = described_class.generate
      expect(@summary.sources).to eq(4)
      expect(@summary.states["invalid"]).to eq(2)
      expect(@summary.level_summary.errors_breakdown[:ragged_rows]).to eq(2)
      expect(@summary.level_summary.warnings_breakdown[:check_options]).to eq(1)
    end

    it "should record categories of problem" do
      mock_file("http://example.com/test4.csv", 'csvs/multiple_errors.csv')
      validation = Legacy::Validation.create_validation("http://example.com/test4.csv")
      @summary = described_class.generate
      expect(@summary.sources).to eq(4)
      expect(@summary.level_summary.errors_breakdown[:ragged_rows]).to eq(2)
      expect(@summary.category_summary.structure_breakdown[:ragged_rows]).to eq(2)
    end

  end

end
