require 'test_helper'

# 永続的セッションのテスト

# current_user内のテストが行われていないので、
# sessions_helper.rbの def current_user内にわざと「例外発生」を仕込む
# →例外が発生していない = つまりテストがうまくいっていない
# Sessionsヘルパーのテストでcurrent_userを直接テストOK
# 【手順】
# ①fixtureでuser変数を定義する
# ②渡されたユーザーをrememberメソッドで記憶する
# ③current_userが、渡されたユーザーと同じであることを確認します
class SessionsHelperTest < ActionView::TestCase

  def setup
    # fixtureにあるmichaelをユーザーとして定義
    @user = users(:michael)
    # ユーザーをrememberの引数として受け取って記憶する
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    # current_user（現在のログインユーザー）とmichaelが同じかどうかテスト

    # assert_equal current_user, @userとかいてもよさそうだが…
    # →assert_equalの引数は「期待する値, 実際の値」の順序で書く
    assert_equal @user, current_user
    # テストユーザーがログイン中ならtrueを返す、何らかの理由でログイン失敗したらfalse
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    # @userの記憶ダイジェストが、ハッシュ化した記憶トークンを暗号化した値と同じなら、
    # 記憶ダイジェストを更新する
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    # 現在のユーザーがnilならtrue(@userが更新できない場合、現在のユーザーがnilになるかどうか検証)
    assert_nil current_user
  end

  # current_userメソッドに仕込んだraiseを削除して元に戻すことで
  # session.helperのテストがパスする
end
