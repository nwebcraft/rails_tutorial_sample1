require 'spec_helper'

describe "Userページ" do

  subject { page }

  describe "signupページ" do
    before { visit signup_path }
    let(:submit) { "アカウントを作成する" }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign Up')) }

    describe "不正なアカウント情報の場合" do
      it "ユーザーが作成されないこと" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "正常なアカウント情報の場合" do
      before do
        fill_in "名前",           with: "サンプル 太郎"
        fill_in "Eメール",         with: "user@example.com"
        fill_in "パスワード",      with: "password"
        fill_in "パスワード(確認)", with: "password"
      end

      it "ユーザーが作成されること" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
  end

  describe "profileページ" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end
