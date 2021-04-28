class Legacy::Schema
  include Mongoid::Document
  store_in collection: "schemas"
  include Mongoid::Timestamps

  field :url, type: String

  has_many :validations, class_name: 'Legacy::Validation'

  def to_param
    id.to_s
  end

end
