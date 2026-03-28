class User < ApplicationRecord
  belongs_to :group, optional: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks
end
