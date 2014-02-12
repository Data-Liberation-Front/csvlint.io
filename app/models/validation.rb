class Validation
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :filename, type: String
  field :url, type: String
  field :schema_url, type: String
  field :state, type: String
  field :result, type: String
end
  