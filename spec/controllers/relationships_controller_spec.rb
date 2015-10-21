require 'spec_helper'

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe "リレーションシップをAjaxで作成する" do

    it "リレーションシップモデルが１つ増えること" do
      expect do
        xhr :post, :create, relationship: { followed_id: other_user.id }
      end.to change(Relationship, :count)
    end

    it "サクセスを応答すること" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end

  describe "リレーションシップをAjaxで削除する" do

    before { user.follow!(other_user) }
    let(:relationship) do
      user.relationships.find_by(followed_id: other_user.id)
    end

    it "リレーションシップが１つ減ること" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end

    it "サクセスを応答すること" do
      xhr :delete, :destroy, id: relationship.id
      expect(response).to be_success
    end
  end
end
