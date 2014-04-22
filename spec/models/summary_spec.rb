require "spec_helper"

describe Summary do
  
  context "when generating summary" do
    before(:each) do
      mock_file("http://example.com/test.csv", 'csvs/valid.csv')
      validation = Validation.create_validation("http://example.com/test.csv")
      
      mock_file("http://example.com/test2.csv", 'csvs/errors.csv')
      validation = Validation.create_validation("http://example.com/test2.csv")
      
      mock_file("http://www.example.com/test3.csv", 'csvs/warnings.csv')
      validation = Validation.create_validation("http://www.example.com/test3.csv")
      
      @summary = Summary.generate
    end
    
    it "should record number of valid sources" do
      @summary.states["valid"].should == 1
    end

    it "should record number of invalid sources" do
      @summary.states["invalid"].should == 1
    end
    
    it "should record number of not found sources" do
      @summary.states["not_found"].should == 0
    end    

    it "should record number of sources with warnings" do
      @summary.states["warnings"].should == 1
    end    
                        
    it "should record number of unique sources" do
      @summary.sources.should == 3
    end
    
    it "should record number of sources per host" do
      @summary.hosts.keys.length.should == 1
      @summary.hosts["example.com"].should == 3
    end    
    
    it "should record occurences of errors" do
      @summary.levels_to_type[:errors][:ragged_rows].should == 1
      @summary.levels_to_type[:warnings][:check_options].should == 1
    end
    
    it "should count occurences across population of sources" do
      mock_file("http://example.com/test4.csv", 'csvs/multiple_errors.csv')
      validation = Validation.create_validation("http://example.com/test4.csv")      
      @summary = Summary.generate
      @summary.states["invalid"].should == 2
      @summary.levels_to_type[:errors][:ragged_rows].should == 2
      @summary.levels_to_type[:warnings][:check_options].should == 1
    end
            
    it "should record categories of problem" do
      mock_file("http://example.com/test4.csv", 'csvs/multiple_errors.csv')
      validation = Validation.create_validation("http://example.com/test4.csv")      
      @summary = Summary.generate

      @summary.levels_to_type[:structure][:ragged_rows].should == 2
      @summary.levels_to_type[:structure][:check_options].should == 1
    end

    
  end
  
end