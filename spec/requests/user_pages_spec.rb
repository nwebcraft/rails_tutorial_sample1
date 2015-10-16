require 'spec_helper'

describe "Userページ" do

  let(:base_title) { "Railsチュートリアル サンプルアプリ" }

  subject { page }

  describe "signupページ" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title("#{base_title} | Sign Up") }
  end
end
