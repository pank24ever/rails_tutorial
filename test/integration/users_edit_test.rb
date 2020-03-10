require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  # test "unsuccessful edit"とtest "successful edit" で
  # log_in_as(@user)を使用しないと、エラーがでる
  # 【原因】→editアクションやupdateアクションでログインを要求するようになったため、
  # ログインしていないユーザーだとこれらのテストが失敗する

  # 編集の失敗に対するテスト
  test "unsuccessful edit" do
    # テストヘルパーのメソッド
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
  end

  # 編集の成功に対するテスト
  test "successful edit" do
    # テストヘルパーのメソッド
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # フォーム欄に値を入力する
    name  = "Foo Bar"
    email = "foo@bar.com"
    # 引数としてわざと失敗する値を持ったuserIDをpatchリクエストで送信（更新）する
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    # エラー文が空じゃなければtrue
    assert_not flash.empty?
    # michaelのユーザーidページへ移動できたらtrue
    assert_redirected_to @user
    # DBから最新のユーザー情報を読み込み直して、正しく更新されたかどうか確認している
    @user.reload
    # DB内の名前と@userの名前が一致していていたらtrue
    assert_equal name,  @user.name
    # DB内のEmailと@userの名前が一致
    assert_equal email, @user.email

    # パスワードとパスワード確認が空であることに注目
    # →ユーザー名やメルアドを編集する時に毎回パスワードを入力するのは不便なので、
    # わざとパスワードを入力せずに更新している
  end

  # フレンドリーフォワーディングのテスト

  # 保護されたページにアクセスしようとすると、問答無用で自分の
  # プロフィールページに移動させられてしまいます。
  # 別の言い方をすれば、
  # ログインしていないユーザーが編集ページにアクセスしようとしていたなら、
  # ユーザーがログインした後にはその編集ページにリダイレクト「される」ようにする
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    # assert_redirected_to edit_user_url(@user)
    # @userのユーザー編集ページへ移動する
    assert_redirected_to edit_user_path(@user)
    # ログインする
    log_in_as(@user)
    # userIDを取得(michael)
    get edit_user_path(@user)

    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
