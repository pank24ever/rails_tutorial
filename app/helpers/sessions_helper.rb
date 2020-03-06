module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーidが自動生成
    # sessionメソッドで作られた一時cookiesは、ブラウザを閉じた瞬間に有効期限が終了
    # 撃者がたとえこの情報をcookiesから盗み出すことができたとしても、
    # それを使って本物のユーザーとしてログインすることはできない
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す (いる場合)
  def current_user
    # if文を使うことで、ユーザーが存在しない場合はnilを返して終わり
    # いない場合でも何回もDBへ問い合わせしていないので早い

    # いる場合は、ログインユーザーのidとDBのidが同じユーザーを返している
    if session[:user_id]
      # User.find(session[:user_id])だとユーザーIDが存在しない状態でfindを使うと例外が発生してしまう

      # User.find_by(id: session[:user_id])だと
      # IDが無効（ユーザーが存在しない）の場合でもメソッドはエラーを発生せずに「nil」を返してくれる

      # 実行結果をインスタンス変数に代入する
      # こうすることで、1リクエスト内におけるDBへの問い合わせは最初の一回だけになり、
      # 以後の呼び出しではインスタンス変数の結果を再利用するだけになる。
      # Webサービスを高速化させる重要なテクニック

      # or演算子「||」
      # ||=は、手前の@current_userがあれば@current_userに代入、なければUser.find〜を代入

      # ログインユーザーがいればそのまま、いなければcookiesのユーザーidと同じidを持つユーザーを
      # DBから探して@current_user（現在のログインユーザー）に代入
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ログインしているか確かめるメソッド
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    # !を先頭に付けることによって、否定演算子(not)を使い、
    # 本来ならnilならtrueの所をnilじゃないならtrueにしている
    !current_user.nil?
  end

  def log_out
    # セッションのuser_idを削除する
    # user_idを引数に取り、sessionにdeleteメソッドを渡す
    session.delete(:user_id)
    # 現在のログインユーザー（一時的なcookies）をnil（空に）する
    @current_user = nil
  end
end
