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
          click_link "Sign out"
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
    let!(:m1)  { FactoryGirl.create(:micropost, user: user, content: "１番目のマイクロポスト") }
    let!(:m2)  { FactoryGirl.create(:micropost, user: user, content: "２番目のマイクロポスト") }

    before { visit user_path(user) }

    describe "ユーザー情報表示" do
      it { should have_content(user.name) }
      it { should have_title(user.name) }
    end

    describe "マイクロポスト表示" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

    describe "フォロー/フォロー解除ボタン" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "ユーザーをフォローする" do
        before { visit user_path(other_user) }

        it "フォローしているユーザー数が増えること" do
          expect do
            click_button 'フォローする'
          end.to change(user.followed_users, :count).by(1)
        end

        it "フォローされたユーザーのフォロワー数が増えること" do
          expect do
            click_button 'フォローする'
          end.to change(other_user.followers, :count).by(1)
        end

        describe "ボタンの表示が切り替わること" do
          before { click_button 'フォローする' }
          it { should have_xpath("//input[@value='フォロー解除する']") }
        end
      end

      describe "ユーザーをフォロー解除する" do
        before do
          user.follow!(other_user)
          visit user_path(other_user)
        end

        it "フォローしているユーザー数が減ること" do
          expect do
            click_button 'フォロー解除する'
          end.to change(user.followed_users, :count).by(-1)
        end

        it "フォロー解除されたユーザーのフォロワー数が減ること" do
          expect do
            click_button 'フォロー解除する'
          end.to change(other_user.followers, :count).by(-1)
        end

        describe "ボタンの表示が切り替わること" do
          before { click_button 'フォロー解除する' }
          it { should have_xpath("//input[@value='フォローする']") }
        end
      end
    end
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

    describe "管理者権限が変更できないこと" do
      let(:params) do
        { user: { admin: true, name: "New name", email: "new@example.com", password: "newpass", password_confirmation: "newpass" } }
      end

      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
  end

  describe "フォロー/フォロワーユーザーページ" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow! other_user }

    describe "フォローしているユーザーのページ" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'フォローしているひと') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "フォロワーのページ" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'フォローされているひと') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
