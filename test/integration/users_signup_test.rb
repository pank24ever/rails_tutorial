require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # ユーザーの新規登録前と後でユーザー数が変わらないかどうか
  # フォームの値を送信（受け取り）できないバリデーションが効いてるかのテスト
  test "invalid signup information" do
    # ユーザー登録ページにアクセス
    get signup_path
    # User.countでユーザー数が変わっていなければ（ユーザー生成失敗）true,変わっていればfalse
    assert_no_difference 'User.count' do
      # signup_pathからusers_pathに対してpostリクエスト送信(/usersへ)、
      # paramsでuserハッシュとその下のハッシュで値を受け取れるか確認
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'

    # ユーザ数を覚えた後にデータを投稿してみて、ユーザ数が変わらないかどうかを検証するテスト
    # ↓のコードと同義！

    # Getリクエストを使用していないのは(↑ではGet)各メソッドに技術的な関連性がなく、
    # ユーザー登録ページにアクセスしなくても、
    # 直接postメソッドを呼び出してユーザー登録ができることを意味しています

    # before_count = User.count
    # post users_path, ...
    # after_count  = User.count
    # assert_equal before_count, after_count
  end

  # 有効なユーザー登録に対するテスト
  # 新規登録が成功（フォーム送信）したかのテスト
  test "valid signup information" do
    get signup_path
    # User.countでユーザー数をカウント、1とし、ユーザー数が変わったらtrue、変わってなければfalse
    # 第一引数(User.count)でユーザー数をカウントしている。第二引数でユーザー数が変わったか確認
    assert_difference 'User.count', 1 do
      # signup_path(/signup)からusers_path(/users)へparamsハッシュのuserハッシュの値を送れるか検証
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # 指定されたリダイレクト先(users/show)へ飛べるか検証
    follow_redirect!
    assert_template 'users/show'
    # :flashに対するテスト
    assert_not   flash.blank?
  end
end
