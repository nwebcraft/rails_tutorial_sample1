class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーのサインイン成功 && ユーザー詳細ページへリダイレクト
      sign_in user
      redirect_to user
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
