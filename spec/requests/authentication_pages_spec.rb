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

    describe "サインイン済ユーザー" do
      let(:user) { FactoryGirl.create(:user) }
      let(:another_user_params) do
          { user: { name: "Another user", email: "another@example.com", password: "password", password_confirmation: "password" } }
      end
      before { sign_in user, no_capybara: true }

      describe "signinページにアクセスした場合" do
        before { get signin_path }
        specify { expect(response).to redirect_to root_url }
      end

      describe "signupページにアクセスした場合" do
        before { get signup_path }
        specify { expect(response).to redirect_to root_url }
      end

      describe "POSTリクエストで登録処理の要求" do
        before { post users_path, another_user_params }
        specify { expect(response).to redirect_to root_url }
      end
    end

    describe "未サインインユーザー" do
      let(:user) { FactoryGirl.create(:user) }

      describe "サインインのリンクのみの表示であること" do
        before { visit root_path }
        it { should     have_link('Sign in',  href: signin_path) }
        it { should_not have_link('Users',    href: users_path) }
        it { should_not have_link('Profile',  href: user_path(user)) }
        it { should_not have_link('Settings', href: edit_user_path(user)) }
        it { should_not have_link('Sign out', href: signout_path) }
      end

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

        describe "PATCHリクエストで更新処理の要求" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "フォローしているユーザーのページ" do
          before { visit following_user_path(user) }
          it { should have_title('Sign In') }
        end

        describe "フォロワーユーザーのページ" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign In') }
        end
      end

      describe "マイクロポストコントローラー内" do

        describe "POSTリクエストで登録処理の要求" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "DELETEリクエストで削除処理の要求" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "リレーションシップコントローラー内" do

        describe "POSTリクエストでの登録処理の要求" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "DELETEリクエストでの削除処理の要求" do
          before { delete relationship_path(1) }
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

          describe "再度サインインしなおした場合はプロフィールページへリダイレクトされること" do
            before do
              click_link "Sign out"
              sign_in user
            end

            it "should render the profile page" do
              expect(page).to have_title(user.name)
            end
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
      let(:non_admin)   { FactoryGirl.create(:user, email: "non_admin@example.com") }
      before { sign_in non_admin, no_capybara: true }

      describe "DELETEリクエストで削除処理を要求" do
        before { delete user_path(target_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "管理者ユーザー" do
      let!(:user) { FactoryGirl.create(:user) }
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin, no_capybara: true }

      describe "DELETEリクエストで削除処理を要求" do

        it "should be able to delete another user" do
          expect do
            delete user_path(user)
          end.to change(User, :count).by(-1)
        end

        it "should not be able to delete self" do
          expect do
            delete user_path(admin)
          end.not_to change(User, :count)
        end
      end
    end
  end
end
