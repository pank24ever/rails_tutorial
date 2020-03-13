require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # usersはfixtureのファイル名users.ymlを表し、
    # :michaelというシンボルはユーザーを参照するためのキーを表す
    @user = users(:michael)
  end

  # ログインしたときのレイアウトの変更をテスト
  test "login with valid information followed by logout" do
    # ログイン用
    get login_path
    # セッション用パスに有効な情報をpost
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # ログイン用リンクが「表示されなくなった」ことを確認する
    assert_select "a[href=?]", login_path, count: 0
    # ログアウト用リンクが「表示されている」ことを確認する
    assert_select "a[href=?]", logout_path
    # プロフィール用リンクが「表示されている」ことを確認する
    assert_select "a[href=?]", user_path(@user)

    #ログアウト用
    delete logout_path
    # テストユーザーのセッションが空、ログインしていなければ（ログアウトできたら）true
    # test/test_helper.rbのメソッド
    assert_not is_logged_in?
    assert_redirected_to root_url

    #2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    # 2回目のログアウトでcurrent_userがないためテストが「失敗することを確認」
    # このままでは、テストは通らないため「sessions_controller.rb」の
    # destroyメソッドに、ログアウトする時はログインしている時という条件式を追加する
    follow_redirect!
    # login_path(/login)がhref=/loginというソースコードで存在していればtrue
    assert_select "a[href=?]", login_path
    # href="/logout"が存在しなければ(0なら)true
    assert_select "a[href=?]", logout_path,      count: 0
    # michaelのidを/user/:idとして受け取った値が存在しなければtrue
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with invalid information" do
    get login_path
    # sessions/new(ログインフォームのビュー)が描画されていればtrue
    assert_template 'sessions/new'
    # ログインURL(/login)のcreateアクションへデータを送り、paramsでsessionハッシュを受け取る
    post login_path, params: { session: { email: "", password: "" } }
    # sessions/new（ログインフォームのビュー）が描画されていればtrue
    assert_template 'sessions/new'
    # flashが空ならfalse、あればtrue
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  # チェックボックスのテスト
  # ログイン時に記憶トークンがcookiesに保存されているか検証
  test "login with remembering" do
    # michaelが有効な値でログインできて、なおかつチェックマーク付けていればtrue
    log_in_as(@user, remember_me: '1')
    # 記憶トークンが空でなければtrue

    # テスト内ではcookiesメソッドにシンボルを使えない
    # そのため、cookies[:remember_token]
    # 上のコードは常にnilになってしまいます
    # 文字列をキーにすればcookiesでも使えるようになるので↓のコードに変更
    # assert_not_empty cookies['remember_token']

    # 記憶トークンが空でなければtrue
    # assignsという特殊なテストメソッドを使うと仮想のremember_token属性にアクセスできるようになる。
    # Sessionsコントローラで定義したインスタンス変数にアクセスするには、
    # テスト内部でassignsメソッドを使う
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  # クッキーの保存の有無をテスト
  test "login without remembering" do
    # クッキーを保存してログイン
    # チェックボックスが「オン」に対するテスト

    # ※remember_meのデフォルト値は1なので、remember_me '1'は省略しても良い
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    # チェックボックスが「オフ」に対するテスト
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
