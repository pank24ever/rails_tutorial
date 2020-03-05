class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end


  def new
    @user = User.new(params[:user])
  end

  # 引数にuser_params(privateメソッド)として使用
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
      flash[:success] = "Welcome to the Sample App!"
    else
      render 'new'
    end
  end

  private

  # paramsハッシュの中を指定する。
  #（requireで:user属性を必須、permitで各属性の値が入ってないとparamsで受け取れないよう指定）
  def user_params
    params.require(:user).permit(:name, :email, :password,:password_confirmation)
  end
end
