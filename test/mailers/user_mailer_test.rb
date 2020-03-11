require 'test_helper'

# Railsによる自動で生成されたテスト
class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    # こちらもデフォルトから変更
    # mail = UserMailer.account_activation
    # assert_equal "Account activation", mail.subject
    # assert_equal ["to@example.org"], mail.to
    # assert_equal ["from@example.com"], mail.from
    # assert_matchは正規表現で文字列をテストできます
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from

    # assert_match "Hi", mail.body.encodedデフォルトから変更
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    # テスト用のユーザーのメールアドレスをエスケープすることもできる
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  test "password_reset" do
    mail = UserMailer.password_reset
    assert_equal "Password reset", mail.subject
    assert_equal ["to@example.org"], mail.to

    # assert_equal ["from@example.com"], mail.fromとチュートリアルでは
    # なっているが、エラーを吐かれる
    # →app/mailer/application_mailer.rbでデフォルト値を変更しているのがわかる
    # →それに合わせたらエラーが治った
    assert_equal ["noreply@example.com"], mail.from
    # assert_matchは正規表現で文字列をテストできます
    assert_match "Hi", mail.body.encoded
  end
end
