class SessionsController < ApplicationController
  before_action :non_signed_in_user, only: :new

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーのサインイン成功 && ユーザー詳細ページへリダイレクト
      sign_in user
      redirect_back_or user
    else
      # エラーメッセージを表示し、サインインフォームを再描画
      flash.now[:error] = "Eメールとパスワードが正しくありません。"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
