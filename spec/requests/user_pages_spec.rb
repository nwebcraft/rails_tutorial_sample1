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

      describe "サブミットボタン押下後にエラーが表示されること" do
        before { click_button submit }

        it { should have_title('Sign Up') }
        it { should have_content('error') }
      end
    end

    describe "正常なアカウント情報の場合" do
      before { valid_user }

      it "ユーザーが作成されること" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "ユーザー作成後にユーザー詳細画面で成功メッセージが表示されること" do
        before { click_button submit }
        let(:user) { User.find_by(email: "user@example.com") }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_success_message('サンプルアプリへようこそ') }
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
