require 'spec_helper'

describe "StaticPages" do

  describe "Home Page" do
    it "should hove the content 'Sample App'" do
      visit '/static_pages/home'
      expect(page).to have_content('Sample App')
    end

    it "should have the title 'Home'" do
      visit '/static_pages/home'
      expect(page).to have_title('Railsチュートリアル サンプルアプリ | Home')
    end
  end

  describe "Help Page" do
    it "should hove the content 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_content('Help')
    end

    it "should have the title 'Help'" do
      visit '/static_pages/help'
      expect(page).to have_title('Railsチュートリアル サンプルアプリ | Help')
    end
  end

  describe "About Page" do
    it "should hove the content 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_content('About Us')
    end

    it "should have the title 'About Us'" do
      visit '/static_pages/about'
      expect(page).to have_title('Railsチュートリアル サンプルアプリ | About Us')
    end
  end
end
