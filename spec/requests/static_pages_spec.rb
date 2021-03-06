require 'spec_helper'

describe "静的ページ" do

  subject { page }

  shared_examples_for "静的ページの表示について" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Homeページ" do
    before { visit root_path }
    let(:heading)    { 'Home' }
    let(:page_title) { '' }

    it_should_behave_like "静的ページの表示について"
    it { should_not have_title(" | Home") }

    describe "サインイン済みユーザーの場合" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "テスト投稿1")
        FactoryGirl.create(:micropost, user: user, content: "テスト投稿2")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "フォロー/フォロワー数を表示すること" do
        let(:other_user1) { FactoryGirl.create(:user) }
        let(:other_user2) { FactoryGirl.create(:user) }
        let(:other_user3) { FactoryGirl.create(:user) }
        let(:other_user4) { FactoryGirl.create(:user) }
        before do
          other_user1.follow!(user)
          other_user2.follow!(user)
          other_user3.follow!(user)
          user.follow!(other_user2)
          user.follow!(other_user4)
          visit root_path
        end

        it { should have_link("2 following", href: following_user_path(user)) }
        it { should have_link("3 followers", href: followers_user_path(user)) }
      end
    end
  end

  describe "Helpページ" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "静的ページの表示について"
  end

  describe "Aboutページ" do
    before { visit about_path }
    let(:heading)    { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "静的ページの表示について"
  end

  describe "Contactページ" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "静的ページの表示について"
  end

  it "should have right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_content('About Us')
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_content('Help')
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_content('Contact')
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_content('Sign up')
    expect(page).to have_title(full_title('Sign Up'))
  end
end
