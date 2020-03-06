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
    assert_not is_logged_in?
    assert_redirected_to root_url
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
end
