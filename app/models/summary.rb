class Summary
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :sources, type: Integer
  field :states, type: Hash
  field :hosts, type: Hash
  field :levels_to_type, type: Hash
  field :categories_to_type, type: Hash
  
  def self.generate
    summary = Summary.create
    
    validations = Validation.where(:url.ne => nil).sort_by{ |v| v.created_at }.reverse!
    validations.uniq!{ |v| v.url }
    
    summary.sources = validations.length
    summary.states = Hash.new 0
    summary.hosts = Hash.new 0
    summary.levels_to_type = Hash.new( Hash.new(0) )
    summary.categories_to_type = Hash.new( Hash.new(0) )
    
    validations.each do |validation|
      summary.states[validation.state] += 1 
      summary.hosts[ source_host(validation) ] += 1
      validator = validation.validator
      messages = []
      [:errors, :warnings, :info_messages].each do |level|
        messages = messages + validator.send(level)
        validator.send(level).uniq { |m| m.type }.each do |msg|
          summary.levels_to_type[ level ][ msg.type ] += 1
        end
      end  
      [:structure, :schema, :context].each do |category|
        messages.reject {|m| m.category != category }.uniq { |m| m.type }.each do |msg|
          summary.categories_to_type[ category ][ msg.type ]
        end
      end
    end
      
    summary
  end
  
  private
  
    def self.source_host(validation)
      host = URI.parse(validation.url).host.downcase
      host.start_with?('www.') ? host[4..-1] : host
    end
    
end