require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "名前が存在しない場合" do
    before { @user.name = "  " }
    it { should_not be_valid }
  end

  describe "名前が30文字を超える場合" do
    before { @user.name = "a" * 31 }
    it { should_not be_valid }
  end

  describe "emailが存在しない場合" do
    before { @user.email = "  " }
    it { should_not be_valid }
  end

  describe "emailが不正な場合" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "emailが正常な場合" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org first.last@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "emailが重複する場合(大文字小文字は区別しない)" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "emailに大文字も入っている場合" do
    let(:mixed_case_email) { "Foo@ExaMPle.CoM" }

    it "全て小文字に変換されて保存されること" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "パスワードが存在しない場合" do
    before do
      @user.password = "   "
      @user.password_confirmation = "  "
    end

    it { should_not be_valid }
  end

  describe "パスワードとパスワード確認が一致しない場合" do
    before { @user.password_confirmation = "mismatch" }

    it { should_not be_valid }
  end

  describe "パスワードが5文字以下の場合" do
    before { @user.password = @user.password_confirmation = "a" * 5 }

    it { should be_invalid}
  end

  describe "パスワード認証で" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "正常なパスワードの場合" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "不正なパスワードの場合" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
end