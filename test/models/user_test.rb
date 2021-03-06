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

  # @user(インスタンスが有効かテスト)
  # 「.valid」メソッドは有効性を図るメソッド
  test "should be valid" do
    assert @user.valid?
  end

  # 名前属性の有効性に対するテスト
  test "name should be present" do
    @user.name = "     "
    # @userが「無効」なら成功、有効なら失敗
    # assert_not だからね！falseならOKってこと！
    assert_not @user.valid?
  end

  # メール属性の有効性に対するテスト
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  # 名前属性の長さに対するテスト
  test "name should not be too long" do
    @user.name = "a" * 51
    # ↑51文字以上は、使えない ↓有効性を図るメソッド
    assert_not @user.valid?
  end

  # メール属性の長さに対するテスト
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # 登録するメールアドレスのテスト
  # 有効なメールフォーマットをテスト
  # →ただの文字列を許容しないように「型」をある程度決めておく
  # 書き方はこれで決まっているのか…？
  test "email validation should accept valid addresses" do
    #5つのアドレスを配列で指定
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    #それぞれの要素をブロックvalid_addressに繰り返し代入。eachで一個ずつ検証
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # inspectメソッドは、オブジェクトや配列などを文字列で返す
      # 第2引数でどのメールアドレスで「失敗」したかエラーメッセージを追加

      # 詳細な文字列を調べるために「inspectメソッド」で調べている
      # →.が,となっていたり、@がないメールアドレスで失敗するかどうかを検証する
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # こちらが、↑とは違って、有効ではないメールのフォーマット
  # →排除するべきフォーマット
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  # 重複するメールアドレス拒否のテスト
  test "email addresses should be unique" do
    #@userを複製する
    # 重複したユーザーを作成する為、dupメソッドを使う
    # →「dup」メソッド = オブジェクトのコピーを作成
    duplicate_user = @user.dup
    # メールアドレスの文字列は大文字小文字の区別がないため、どちらの場合も検証しなければならない
    #複製したduplicate_userのメールアドレス欄の文字列を大文字にする

    # しかし、複製したユーザーのメールアドレスを大文字にしたもののvalidationがtrueになっている
    # →同じメールアドレスが複製可能となっている(大文字、少文字で区別はつけれている)

    # それではいけないので、モデルに:uniquenessに:case_sensitiveオプションをつける
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  # メールアドレスを小文字にするテスト
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.Com"
    @user.email = mixed_case_email
    @user.save
    # 値が一致しているかどうか確認する
    #第一引数で@userのEmailを小文字に変換、
    # 第二引数でDBからEmail(大文字小文字混同のemail)を再読み込み、
    # この二つが同一であればtrueを返す
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
    # assert_not @user.authenticated?('')

    # Userテスト内の抽象化したauthenticated?メソッド
    # @userのユーザーの記憶ダイジェストと、引数で受け取った値が同一ならfalse、異なるならtrueを返す
    assert_not @user.authenticated?(:remember, '')
  end
end
