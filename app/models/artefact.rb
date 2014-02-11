class Artefact
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :filename, type: String
  field :url, type: String
  field :error_messages, type: Array
  field :warning_messages, type: Array
end
  