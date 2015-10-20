require 'spec_helper'

describe "Micropostページ" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  let(:submit) { '投稿する' }

  describe "マイクロポストの投稿" do
    before { visit root_path }

    describe "不正なマイクロポスト情報の場合" do
      it "マイクロポストが作成されないこと" do
        expect { click_button submit }.not_to change(Micropost, :count)
      end

      describe "サブミットボタン押下後にエラーが表示されること" do
        before { click_button submit }

        it { should have_content('error') }
      end
    end

    describe "正常なマイクロポスト情報の場合" do
      before { fill_in "投稿内容", with: "テスト投稿" }

      it "マイクロポストが作成されること" do
        expect { click_button submit }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "マイクロポストの削除" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "正しいユーザーの場合" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "削除" }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
