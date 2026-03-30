class User < ApplicationRecord
  before_validation :set_group
  belongs_to :group

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tasks

  validates :name, presence: true
  validates :email, presence: true
  validates :password, format: { with: /\A(?=.*?[a-z])(?=.*?\d)[a-z\d]+\z/i, message: 'は半角英数字混合で入力してください' }
  
  def set_group
    self.group ||= Group.first || Group.create!(name: "デフォルトグループ")
  end
end
