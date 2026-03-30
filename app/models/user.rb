class User < ApplicationRecord
  before_validation :set_group
  belongs_to :group

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks

  validates :name, presence: true
  
  def set_group
    self.group ||= Group.first || Group.create!(name: "デフォルトグループ")
  end
end
