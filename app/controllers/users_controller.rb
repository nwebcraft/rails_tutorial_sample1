class UsersController < ApplicationController
  before_action :non_signed_in_user, only: [:new, :create]
  before_action :signed_in_user,     only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,       only: [:edit, :update]
  before_action :admin_user,         only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "サンプルアプリへようこそ！"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールを更新しました"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "ユーザーは削除されました"
    redirect_to users_url
  end

  def following
    page_info = { title: 'Following', h3: 'フォローしているひと' }
    user  = User.find(params[:id])
    users = user.followed_users.paginate(page: params[:page], per_page: 10)
    render 'show_follow', locals: { page_info: page_info, user: user, users: users }
  end

  def followers
    page_info = { title: 'Followers', h3: 'フォローされているひと' }
    user  = User.find(params[:id])
    users = user.followers.paginate(page: params[:page], per_page: 15)
    render 'show_follow', locals: { page_info: page_info, user: user, users: users }
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user? @user
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
      @user = User.find(params[:id])
      redirect_to root_url if current_user? @user
    end
end