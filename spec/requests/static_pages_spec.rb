require 'spec_helper'

describe "静的ページ" do

  #let(:base_title) { "Railsチュートリアル サンプルアプリ" }

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
