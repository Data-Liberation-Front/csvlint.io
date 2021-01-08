class Schema < ActiveRecord::Base
  has_many :validations

  validates :url, presence: true

  def to_param
    id.to_s
  end

end
