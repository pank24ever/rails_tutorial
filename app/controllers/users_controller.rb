class UsersController < ApplicationController
  # デフォルトで、コントローラ内の全てのアクションに適用されるので、
  # :onlyオプションを渡すことで、editとupdateというアクションのみフィルタを適用されるよう制限
  before_action :logged_in_user, only: [:index,:edit,:update,:destroy]
  # 別のユーザーのプロフィールを編集しようとしたらリダイレクトさせたい
  # 編集/更新ページを保護する
  before_action :correct_user,   only: [:edit, :update]
  # コマンドラインで「DELETEリクエストを直接発行する」という方法で
  # サイトの全ユーザーを削除してしまうことができる
  # →destroyアクションにもアクセス制御を行う
  # →beforeフィルターでdestroyアクションを管理者だけに限定する
  before_action :admin_user,     only: :destroy

  def index
    # @users = User.all↓変更する
    # @users = User.allのままでは、ページネーションは動かない
    # →paginateメソッドを使った結果が必要だから
    # @users = User.paginate(page: params[:page]) ↓変更

    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    # activatedがfalseならルートURLヘリダイレクト
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new(params[:user])
  end

  # 引数にuser_params(privateメソッド)として使用
  def create
    @user = User.new(user_params)
    if @user.save
      # ユーザーモデルオブジェクトからメールを送信する
      # アカウント有効化メールの送信
      @user.send_activation_email

      # SessionsHelperのログインするメソッド
      # log_inメソッド(ログイン)の引数として@user(ユーザーオブジェクト)を渡す。
      # 要はセッションに渡すってこと
      # log_in @user
      # redirect_to @user
      # flash[:success] = "Welcome to the Sample App!"

      # ユーザー登録にアカウント有効化を追加
      # アカウント有効化メールの送信

      # リダイレクト先をプロフィールページからルートURLに変更し、
      # かつユーザーは以前のようにログインしないようになっています

      # 11.36:で消えた
      # UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # update_attributesを使って送信されたparmasハッシュに基づいて、ユーザーを更新
    # 無効な情報が送信された場合、更新の結果としてfalseが返され、
    # elseに分岐して編集ページをレンダリング

    # 引数に注目！Strong Parametersを使って、マスアサインメントの脆弱性を防止
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    # 理者だけがユーザーを削除できる
    # paramsで現在(管理者)のIDを探して、そのまま削除ができるようにしている
    User.find(params[:id]).destroy
    flash[:success] = "削除完了"
    redirect_to users_url
  end

  private

  # paramsハッシュの中を指定する。
  #（requireで:user属性を必須、permitで各属性の値が入ってないとparamsで受け取れないよう指定）
  def user_params
    params.require(:user).permit(:name, :email, :password,:password_confirmation)
  end

  # beforeアクション

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    # sessionhelperのメソッド
    # ユーザーがログインしていなければ(false)処理を行う
    unless logged_in?
      # session.helperあるアクセスしようとしたURLを覚えておくメソッド
      # →ログインできなかった場合、アクセスしようとしたURLを記憶する
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # 正しいユーザーかどうか確認
  def correct_user
    # URLのidの値と同じユーザーを@userに代入
    @user = User.find(params[:id])
    # @userと記憶トークンcookieに対応するユーザー(current_user)を比較して、
    # 失敗したらroot_urlへリダイレクト
    # ログインユーザーとURLに入力されたユーザーが異なっていれば、root_urlに飛ばす

    # redirect_to(root_url) unless @user == current_userする
    # →current_user?という論理値を返すメソッドを実装する
    # →sessions_helper.rbに実装
    redirect_to(root_url) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    # 現在のユーザーが管理者でなければroot_urlへリダイレクト
    redirect_to(root_url) unless current_user.admin?
  end
end
