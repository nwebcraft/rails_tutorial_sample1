require 'spec_helper'

describe "認証ページ" do

  subject { page }

  describe "signinページ" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign In') }

    describe "不正なサインイン情報の場合" do
      before { click_button 'サインイン' }

      it { should have_title('Sign In') }
      it { should have_error_message('正しくありません') }

      describe "サインインフォーム再描画後にHome画面遷移するとエラーメッセージが表示されないこと" do
        before { click_link 'Home'}

        it { should_not have_error_message('正しくありません') }
      end
    end

    describe "正常なサインイン情報の場合" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "サインアウト後にサインインリンクが表示されること" do
        before { click_link "Sign out" }

        it { should have_link('Sign in') }
      end
    end
  end
end
