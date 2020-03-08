class User < ApplicationRecord
  attr_accessor :remember_token

  # validates :name, presence: true,length: { maximum: 50 }
  # validates :email, presence: true,length: { maximum: 255 }

  # 正規表現で書き直す

  # email属性を小文字に変換してメールアドレスの一意性を保証するコールバックメソッド
  # →なぜか…大文字小文字の関係で同じ文字の並びなのに、違うメールと判断されないようにするため
  # before_save { self.email = self.email.downcase }でも可能

  # before_save { self.email = email.downcase } ↓またさらに変更する
  # 破壊的メソッドを使い、selfを使わずにemailの文字列を小文字に変換
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    # uniqueness: true, ↓このままでは一意性検証では
                    # 大文字小文字で区別はされているが同じメールアドレスが複製可能となっている
                    uniqueness: { case_sensitive: false }
  has_secure_password

  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  #fixture(テスト用のユーザーデータを流し込む場所的な)用に、
  # password_digestの文字列をハッシュ化して、ハッシュ値として返す
  def User.digest(string)
    # min_costでコストパラメータを最小にし、
    # costでしっかりとしたコストパラメータを渡している。
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # string=ハッシュ化する文字列 cost=コストパラメータ
    BCrypt::Password.create(string, cost: cost)
  end

  # def self.digest(string) ↑↑↑
  #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #                                                 BCrypt::Engine.cost
  #   BCrypt::Password.create(string, cost: cost)
  # end

  # ランダムなトークンを返す
  def User.new_token
    # 記憶トークン作成のメソッド
    # URLのトークン化・パスワードのトークン化にbase64が使える
    # ランダムな文字列を生成する
    SecureRandom.urlsafe_base64
  end

  # def self.new_token ↑↑↑
  #   SecureRandom.urlsafe_base64
  # end

  # 永続セッションのためにユーザーをデータベースに記憶する
  # 記憶トークンをユーザーオブジェクトに代入し、DBのデータを更新する
  def remember
    # remeber_tokenをUserクラスオブジェクトの属性として扱うには、
    # selfメソッド（オブジェクト自身）に対してインスタンス変数を渡す
    # selfというキーワードを使わないと、Rubyによってremember_tokenという名前のローカル変数が作成されてしまう

    # User.new_tokenで記憶トークンを作成
    # 記憶トークンをremember_token属性に代入
    self.remember_token = User.new_token
    # DBに対して記憶ダイジェストを更新せよという命令
    # User.digestを適用した結果で記憶ダイジェストを更新
    # DBのremember_token属性値をBcryptに渡してハッシュ化して更新
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがユーザーの記憶ダイジェストと一致することを確認
  # 攻撃者がidとパスワードのcookieを奪い取ったとしても、最後のBCryptによる、
  # 記憶トークンと記憶ダイジェストの一致が不可能なため、ログインできないということになる

  # BCrypt::Password.new(password_digest) == unencrypted_password
  # とかけばよさそうだが…↑は、BCryptは復号できない作りに…

  # しかし…！！
  # ↓とかけばよさそう！
  # BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # is_password?は論理値メソッドであり、== の代わりに比較として使える
  # 比較に使っている==演算子ならOK

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    # 「user_test.rb」test "authenticated? should return~"をクリアさせる
    # 記憶ダイジェストがnilの場合にfalseを返す
    # 記憶ダイジェストがnilの場合、returnでfalseを返すことで、即座にメソッドを終了している

    # →処理を中途で終了する場合によく使われる使いかた
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  # user.remember「上にあるユーザーを覚えるメソッド」が取り消され
  def forget
    # DBにある記憶ダイジェストをnilにする
    update_attribute(:remember_digest, nil)
  end
end
