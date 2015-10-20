require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "micropostテスト") }

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "ユーザーID(user_id)が存在しない場合" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "contentが空の場合" do
    before { @micropost.content = "    " }
    it { should_not be_valid }
  end

  describe "contentが140文字を超える場合" do
    before { @micropost.content = 'a' * 141 }
    it { should_not be_valid }
  end
end