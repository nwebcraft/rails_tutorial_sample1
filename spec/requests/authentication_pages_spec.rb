require 'spec_helper'

describe "認証" do

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
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile',  href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "サインアウト後にサインインリンクが表示されること" do
        before { click_link "Sign out" }

        it { should have_link('Sign in') }
      end
    end
  end

  describe "権限" do

    describe "未サインインユーザー" do
      let(:user) { FactoryGirl.create(:user) }

      describe "ユーザーコントローラー内" do

        describe "ユーザー一覧ページ" do
          before { visit users_path }
          it { should have_content('サインインしてください') }
        end

        describe "編集ページ" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign In') }
          it { should have_content('サインインしてください') }
        end

        describe "更新処理の要求(PATCHリクエスト)" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "編集ページにアクセスした場合" do
        before do
          visit edit_user_path(user)
          fill_in "Eメール",   with: user.email
          fill_in "パスワード", with: user.password
          click_button 'サインイン'
        end

        describe "サインイン後に保護ページへリダイレクトされること" do

          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end
    end

    describe "不正ユーザー" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "編集ページにGETリクエスト" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "PATCHリクエストで更新処理要求" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "非管理者ユーザー" do
      let(:target_user) { FactoryGirl.create(:user) }
      let(:non_admin)   { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true }

      describe "DELETEリクエストで削除処理を要求" do
        before { delete user_path(target_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
