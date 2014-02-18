class Schema
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url, type: String

  has_many :validations

  def to_param
    id.to_s
  end

end
  