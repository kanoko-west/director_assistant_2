require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    it 'nameが空では登録できない' do
      user = FactoryBot.build(:user)
      user.name = ''
      user.valid?
      expect(user.errors.full_messages).to include("Name can't be blank")
    end
  end
end
