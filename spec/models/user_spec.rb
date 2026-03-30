require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ユーザー新規登録' do
    it 'nameが空では登録できない' do
      user = User.new(name: '', email: 'test@example', password: 'abc123', password_confirmation: 'abc123')
      user.valid?
      expect(user.errors.full_messages).to include("Name can't be blank")
    end
  end
end
