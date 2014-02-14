class Schema
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url, type: String

  has_many :validations

end
  