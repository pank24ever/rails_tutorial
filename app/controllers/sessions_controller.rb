class SessionsController < ApplicationController
  def new
  end

  def create
    # 全ての大文字を対応する小文字に置き換えた文字列
    # paramsハッシュから値をうけとって、少文字化する。そして、Userモデルに検索をかける
    user = User.find_by(email: params[:session][:email].downcase)
    # [望ましい結果 ]有効なユーザー&&正しいパスワード	(true && true) == true
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする

      # SessionsHelperの「log_in」メソッド↓
      # sessionメソッドのuser_id（ブラウザに一時cookiesとして保存）にidを送る
      log_in user
      redirect_to user
    else
      # エラーメッセージを作成する

      # ↓は間違い→renderでnewビューを再描画した際にリクエストと見なされない
      # （flashからサーバーへの削除リクエストが行われない）ので、別ページに移動しても
      # flashメッセージは削除されず、残り続けてしまう

      # 【解決策】nowメソッドを使用する
      # nowメソッドはレンダリングが終わっているページで特別にフラッシュメッセージを表示できる

      # flash[:dammnger] = 'Invalid email/password combination'
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # SessionsHelperのログアウトするメソッドを呼び出している
    log_out
    redirect_to root_url
  end
end
