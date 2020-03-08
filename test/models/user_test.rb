require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # setupメソッドでは、インスタンス変数を宣言することでテスト内でその変数が使える
  def setup
    # has_secure_passwordを使用することによって
    # password属性とpassword_confirmation属性に対してバリデーションをする機能も
    # 強制的に追加する
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    # @userが無効なら成功、有効なら失敗
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # 登録するメールアドレスのテスト
  # 書き方はこれで決まっているのか…？
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # inspectメソッドは、オブジェクトや配列などを文字列で返す
      # 第2引数でどのメールアドレスで失敗したかエラーメッセージを追加
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 重複するメールアドレス拒否のテスト
  test "email addresses should be unique" do
    #@userを複製する
    # 重複したユーザーを作成する為、dupメソッドを使う
    duplicate_user = @user.dup
    # メールアドレスの文字列は大文字小文字の区別がないため、どちらの場合も検証しなければならない
    #複製したduplicate_userのメールアドレス欄の文字列を大文字にする

    # しかし、複製したユーザーのメールアドレスを大文字にしたもののvalidationがtrueになっている
    # 同じメールアドレスが複製可能となっている
    # それではいけないので、モデルに:uniquenessに:case_sensitiveオプションをつける
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.Com"
    @user.email = mixed_case_email
    @user.save
    # 値が一致しているかどうか確認する
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # パスワードが空白か確認するテスト
  test "password should be present (nonblank)" do
    # =が二つ付いている、このような構文を多重代入(multiple Assignment)と呼ぶ
    # 上記の文では@user.passwordと@user.password_confirmationに"aaaaa"を代入
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  # パスワードの最小文字数を決めるテスト
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # ダイジェストが存在しない場合のauthenticated?のテスト
  # authenticatedメソッドで記憶ダイジェストを暗号化できるか検証
  test "authenticated? should return false for a user with nil digest" do
    # @userのユーザーの記憶ダイジェストと引数で受け取った値が同一ならfalse、異なるならtrueを返す
    assert_not @user.authenticated?('')
  end
end
