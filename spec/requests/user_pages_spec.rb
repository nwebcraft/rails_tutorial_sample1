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

  describe "一覧ページ" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('ユーザー一覧') }

    describe "ページネーション" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "削除リンク" do

      it { should_not have_link('delete') }

      describe "管理者ユーザー" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

  describe "profileページ" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "編集ページ" do
    let(:user) { FactoryGirl.create(:user) }
    let(:submit) { "編集を保存する" }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "表示内容" do
      it { should have_content('プロフィールの編集') }
      it { should have_title('Edit user') }
      it { should have_link('変更', href: 'http://gravatar.com/emails') }
    end

    describe "不正な編集情報の場合" do
      before { click_button submit }

      it { should have_content('error') }
    end

    describe "正常な編集情報の場合" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com"}
      before do
        fill_in "名前",           with: new_name
        fill_in "Eメール",         with: new_email
        fill_in "パスワード",      with: user.password
        fill_in "パスワード(確認)", with: user.password
        click_button "編集を保存する"
      end

      it { should have_title(new_name) }
      it { should have_success_message('プロフィールを更新しました') }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end
