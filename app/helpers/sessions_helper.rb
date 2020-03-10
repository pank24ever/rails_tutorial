module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # ユーザーのブラウザ内の一時cookiesに暗号化済みのユーザーidが自動生成
    # sessionメソッドで作られた一時cookiesは、ブラウザを閉じた瞬間に有効期限が終了
    # 撃者がたとえこの情報をcookiesから盗み出すことができたとしても、
    # それを使って本物のユーザーとしてログインすることはできない
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  # rememberメソッドにuser(ログイン時にユーザーが送ったメールとパスと同一の、DBにいるユーザー)を引数として渡す
  def remember(user)
    # SessionsHelperのメソッド
    # ログイン時のユーザーと同一のDBのユーザーに、記憶トークンを生成して
    # 記憶ダイジェストにハッシュ化したハッシュ値を持たせて保存
    user.remember
    # ログイン時のユーザーidを、有効期限(20年)と署名付きの暗号化したユーザーidとしてcookiesに保存
    cookies.permanent.signed[:user_id] = user.id
    # ログイン時の記憶トークンを、有効期限（20年）を設定して新たなremember_tokenに保存
    # Userモデルにて、ログインユーザーと同一ならtrueを返す

    # user.rbのremember_tokenメソッド
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # # if文を使うことで、ユーザーが存在しない場合はnilを返して終わり
    # # いない場合でも何回もDBへ問い合わせしていないので早い

    # # いる場合は、ログインユーザーのidとDBのidが同じユーザーを返している
    # 現在ログイン中のユーザーを返す (いる場合)
    # if session[:user_id]
    #   # User.find(session[:user_id])だとユーザーIDが存在しない状態でfindを使うと例外が発生してしまう

    #   # User.find_by(id: session[:user_id])だと
    #   # IDが無効（ユーザーが存在しない）の場合でもメソッドはエラーを発生せずに「nil」を返してくれる

    #   # 実行結果をインスタンス変数に代入する
    #   # こうすることで、1リクエスト内におけるDBへの問い合わせは最初の一回だけになり、
    #   # 以後の呼び出しではインスタンス変数の結果を再利用するだけになる。
    #   # Webサービスを高速化させる重要なテクニック

    #   # or演算子「||」
    #   # ||=は、手前の@current_userがあれば@current_userに代入、なければUser.find〜を代入

    #   # ログインユーザーがいればそのまま、いなければcookiesのユーザーidと同じidを持つユーザーを
    #   # DBから探して@current_user（現在のログインユーザー）に代入
    #   @current_user ||= User.find_by(id: session[:user_id])
    # end


    # ↑のコードでは、ログインするユーザーはブラウザで有効な記憶トークンを得られるように記憶されているが、
    # current_userメソッドでは一時セッションしか扱っておらず、
    # このままでは正常に動作しない。
    # つまり、今のままでは現在のログイン中ユーザーがいない場合、
    # 全部sessionID（一時的なid）がcookieとして保存されてしまう

    # if session[:user_id]
    #   @current_user ||= User.find_by(id: session[:user_id])
    # elsif cookies.signed[:user_id]
    #   user = User.find_by(id: cookies.signed[:user_id])
    #   if user && user.authenticated?(cookies[:remember_token])
    #     log_in user
    #     @current_user = user
    #   end
    # end

    # ↑のコードでもいいが…
    # sessionメソッドとcookiesメソッドをそれぞれ二回ずつ使っているので、
    # これを綺麗にするためローカル変数を使う

    # セッションユーザーidをユーザーidに代入した結果、ユーザーIDのセッションが存在すればtrueとなる
    # 代入とsession[:user_id]があるかどうかを一回で条件式にしている
    # 一時的なセッションユーザーがいる場合処理を行い、user_idに代入
    if (user_id = session[:user_id])
      # 現在のユーザーがいればそのまま、いなければsessionユーザーidと同じidを持つユーザーを
      # DBから探して@current_user（現在のログインユーザー）に代入
      @current_user ||= User.find_by(id: user_id)
      # user_idを暗号化した永続的なユーザーがいる（cookiesがある）場合処理を行い、user_idに代入
    elsif (user_id = cookies.signed[:user_id])

      # raise       # テストがパスすれば、この部分がテストされていないことがわかる
      # テストを書き直したので、コメントアウト(削除)する

      # 暗号化したユーザーidと同じユーザーidをもつユーザーをDBから探し、userに代入
      user = User.find_by(id: user_id)
      # DBのユーザーがいるかつ、受け取った記憶トークンをハッシュ化した記憶ダイジェストを持つ
      # ユーザーがいる場合処理を行う
      if user && user.authenticated?(cookies[:remember_token])
        # 一致したユーザーでログインする
        log_in user
        # 現在のユーザーに一致したユーザーを設定
        @current_user = user
      end
    end
  end

  # ログインしているか確かめるメソッド
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    # !を先頭に付けることによって、否定演算子(not)を使い、
    # 本来ならnilならtrueの所をnilじゃないならtrueにしている
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  # ログイン時に送ったuserのIDとパスワードと同一のユーザーを引数として渡す
  def forget(user)
    # userに対してforgetメソッドを呼び出し、記憶ダイジェストをnilにする
    user.forget
    # cookiesのuser_idを削除
    cookies.delete(:user_id)
    # cookiesのremeber_tokenを削除
    cookies.delete(:remember_token)
  end

  # # 今のままだと問題点が2つ！
  # # ①二つのタブを用意して、片方でログアウトした後に、もう片方でログアウトするとエラーとなる
  # →問題を回避するためには、ユーザーがログイン中の場合にのみログアウトさせる必要がある

  # ②ユーザーがFirefoxとChromeでログインしていたとして、Firefoxでログアウトする
  # そして、Chromeではロウアウトせずに、ブラウザを終了させ、再度開くとエラーとなってしまう。
  # 【理由】まずFirefoxでログアウトすると、
  # user.forgetメソッドによってremember_digest(記憶ダイジェスト)がnilとなる。
  # この時点で、Firefoxでまだアプリが正常に動作しているはずなので、
  # log_outメソッドによってユーザーidが削除される。
  # user_idが消えたことにより、current_userメソッドのユーザーidの条件式で、どちらもfalseとなる

  # →2つの条件はfalseになる
  # 上のcurrent_userメソッドの「if」「elsif」
  # →current_userメソッドの最終的な評価結果は、期待どおりnilになります

  def log_out
    # ↑のメソッド
    forget(current_user)
    # 引数として現在のログインユーザーを受け取り、forgetメソッドで記憶ダイジェストを削除
    # セッションのuser_idを削除する
    # user_idを引数に取り、sessionにdeleteメソッドを渡す
    session.delete(:user_id)
    # 現在のログインユーザー（一時的なcookies）をnil（空に）する
    @current_user = nil
  end

  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  # リクエストされたURLが「存在する」場合はそこにリダイレクトし、
  # 「ない場合」は何らかのデフォルトのURLにリダイレクト
  def redirect_back_or(default)
    # or演算子||
    # session[:forwarding_url] || default
    # このコードは、値がnilでなければsession[:forwarding_url]を評価し、
    # そうでなければデフォルトのURLを使っています
    redirect_to(session[:forwarding_url] || default)
    # 転送用のURLを削除している
    # →次回ログインしたときに保護されたページに転送されてしまい、
    # ブラウザを閉じるまでこれが繰り返されてしまう
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    # GETリクエストが送られたときだけ格納するようにする
    # →例えばログインしていないユーザーがフォームを使って送信した場合、
    # 転送先のURLを保存させないようにする

    # ユーザがセッション用のcookieを手動で削除して、フォームから送信するとする
    # こういったケースに対処しておかないと、
    # POSTやPATCH、DELETEリクエストを期待しているURLに対して、GETリクエストが送られてしまい、
    # 場合によってはエラーが発生する。
    # これらの問題を
    # if request.get?という条件文を使って対応
    session[:forwarding_url] = request.original_url if request.get?
  end
end
