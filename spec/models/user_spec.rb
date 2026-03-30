require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end
  
  describe 'ユーザー新規登録' do
    context '新規登録できるとき' do
      it 'nameとemail、passwordとpassword_confirmationが存在すれば登録できる' do
        expect(@user).to be_valid
      end
    end  

    context '新規登録できないとき' do
      it 'nameが空では登録できない' do
        user = FactoryBot.build(:user, name: '')
        user.valid?
        expect(user.errors[:name]).to include("can't be blank")
      end

      it 'emailが空では登録できない' do
        user = FactoryBot.build(:user, email: '')
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'passwordが空では登録できない' do
        user = FactoryBot.build(:user, password: '', password_confirmation: '')
        user.valid?
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'passwordとpassword_confirmationが不一致では登録できない' do
        user = FactoryBot.build(:user, password_confirmation: 'invalid')
        user.valid?
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it '重複したemailで登録できない' do
        @user.save
        another_user = FactoryBot.build(:user, email: @user.email)
        another_user.valid?
        expect(another_user.errors[:email]).to include("has already been taken")
      end

      it 'passwordが5文字以下では登録できない' do
        user = FactoryBot.build(:user, password: '12345', password_confirmation: '12345')
        user.valid?
        expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
      end

      it 'passwordが129文字以上では登録できない' do
        password = 'a' * 130
        user = FactoryBot.build(:user, password: password, password_confirmation: password)
        user.valid?
        expect(user.errors[:password]).to include("is too long (maximum is 128 characters)")
      end
    end
  end
end
