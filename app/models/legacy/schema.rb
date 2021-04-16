class Legacy::Schema
  include Mongoid::Document
  store_in collection: "schemas"
  include Mongoid::Timestamps

  field :url, type: String

  has_many :validations

  def to_param
    id.to_s
  end

end
