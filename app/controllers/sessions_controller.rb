class SessionsController < ApplicationController
  def new
  end

  # def create
  #   # 全ての大文字を対応する小文字に置き換えた文字列
  #   # paramsハッシュから値をうけとって、少文字化する。そして、Userモデルに検索をかける
  #   # user = User.find_by(email: params[:session][:email].downcase)

  #   # コントローラで定義したインスタンス変数にテストの内部からアクセスするには、
  #   # テスト内部でassignsメソッドを使うとできる

  #   # なぜ「user」ローカル変数から、「@user」インスタンス変数に変換したのか…？
  #   # →cookiesにユーザー記憶トークンが正しく含まれているかどうかテストできるようになるから
  #   @user = User.find_by(email: params[:session][:email].downcase)
  #   # [望ましい結果 ]有効なユーザー&&正しいパスワード	(true && true) == true
  #   # if user && user.authenticate(params[:session][:password])

  #   if @user && @user.authenticate(params[:session][:password])
  #     # ユーザーログイン後にユーザー情報のページにリダイレクトする

  #     # SessionsHelperの「log_in」メソッド↓
  #     # sessionメソッドのuser_id（ブラウザに一時cookiesとして保存）にidを送る
  #     # log_in user

  #     log_in @user
  #     # チェックボックスの送信結果の処理
  #     # チェックボックスがオフ、つまり0という意味を表している。チェックボックスがオンなら1が記入
  #     # 三項演算子で記入されている

  #     # params[:session][:remember_me] ? remember(user) : forget(user)でも
  #     # よさそうだが…
  #     # paramsの値が存在すればremember_meを返し、存在しなければforgetを返す

  #     # これも1(true)と0(false)を返している
  #     # しかし、Rubyの論理値では0も1もtrueとなるので、値は常にtrueになってしまい、
  #     # チェックボックスは常にオンになっているのと同じ動作になってしまう。
  #     # なので、 == '1'と条件を指定する必要がある
  #     # params[:session][:remember_me] == '1' ? remember(user) : forget(user)

  #     params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
  #     # user.rbのメソッド
  #     # redirect_to user


  #     # redirect_to @user↓変更
  #     # session.helperにある記憶したURL (もしくはデフォルト値) にリダイレクトメソッド
  #     # redirect_back_or user
  #     # Tutorialでは@userではなくuserが使われているが、使うとusers_login_testでエラーが発生
  #     redirect_back_or @user
  #   else
  #     # エラーメッセージを作成する

  #     # ↓は間違い→renderでnewビューを再描画した際にリクエストと見なされない
  #     # （flashからサーバーへの削除リクエストが行われない）ので、別ページに移動しても
  #     # flashメッセージは削除されず、残り続けてしまう

  #     # 【解決策】nowメソッドを使用する
  #     # nowメソッドはレンダリングが終わっているページで特別にフラッシュメッセージを表示できる

  #     # flash[:dammnger] = 'Invalid email/password combination'
  #     flash.now[:danger] = 'Invalid email/password combination'
  #     render 'new'
  #   end
  # end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # 有効でないユーザーがログインすることのないようにする
      # @userが有効の処理
      if @user.activated?
        # sessions_helperのlog_inメソッドを実行し、
        # sessionメソッドの@user_id（ブラウザに一時cookiesとして保存）にidを送る
        log_in @user
        # ログイン時、sessionのremember_me属性が1(チェックボックスがオン)なら
        # セッションを永続的に、それ以外なら永続的セッションを破棄する
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # SessionsHelperのログアウトするメソッドを呼び出している

    # 統合テストにdelete logout_pathを追加し、
    # 2回目のログアウトでcurrent_@userがないためテストが失敗することを確認した上で
    # テストが通らないために、ログアウトする時はログインしている時という条件式を追加する
    # log_out ↓から変更

    # ユーザーがログインしていればログアウトする
    log_out if logged_in?
    redirect_to root_url
  end
end
