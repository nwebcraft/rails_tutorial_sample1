require 'spec_helper'

describe "静的ページ" do

  let(:base_title) { "Railsチュートリアル サンプルアプリ" }

  subject { page }

  describe "Homeページ" do
    before { visit root_path }

    it { should have_content('Home') }
    it { should have_title("#{base_title}") }
    it { should_not have_title(" | Home") }
  end

  describe "Helpページ" do
    before { visit help_path }

    it { should have_content('Help') }
    it { should have_title("#{base_title} | Help") }
  end

  describe "Aboutページ" do
    before { visit about_path }

    it { should have_content('About Us') }
    it { should have_title("#{base_title} | About Us") }
  end

  describe "Contactページ" do
    before { visit contact_path }

    it { should have_content('Contact') }
    it { should have_title("#{base_title} | Contact") }
  end
end
