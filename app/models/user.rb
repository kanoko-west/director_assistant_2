class User < ApplicationRecord
  before_validation :set_group

  def set_group
    self.group_id ||= 1
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
