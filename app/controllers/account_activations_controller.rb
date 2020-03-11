class AccountActivationsController < ApplicationController

  # アカウントを有効化するeditアクション
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # ユーザーモデルオブジェクト経由でアカウントを有効化
      user.activate
      # # 日付更新ができる2つのコード
      # user.update_attribute(:activated,    true)
      # user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
