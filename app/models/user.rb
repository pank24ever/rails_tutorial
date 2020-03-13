class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  # 2つとも「コールバック」メソッド
  # before_saveがbefore_createよりも先に実行される
  # →「create」して「save」ではない
  # オブジェクトがDBに保存される直前で実行
  before_save   :downcase_email
  # オブジェクトがDBに新規保存(INSERT)される直前で実行
#   オブジェクトが作成された時だけコールバックを呼び出したい。
# （それ以外の時は呼び出したくない）メソッド参照と呼ばれる
  before_create :create_activation_digest

  # validates :name, presence: true,length: { maximum: 50 }
  # validates :email, presence: true,length: { maximum: 255 }

  # 正規表現で書き直す

  # email属性を小文字に変換してメールアドレスの一意性を保証するコールバックメソッド
  # →なぜか…大文字小文字の関係で同じ文字の並びなのに、違うメールと判断されないようにするため
  # before_save { self.email = self.email.downcase }でも可能

  # DBレベルでは一意性をまだ保てていないため設定していく
  # →Foo@ExAMPle.Comとfoo@example.comが別々の文字列と解釈してしまうので
  # DBに保存される前に、すべて少文字にしてしまって保存するように
  # コールバックメソッドを使用していく

  # before_save { self.email = email.downcase } ↓またさらに変更する
  # 破壊的メソッドを使い、selfを使わずにemailの文字列を小文字に変換
  # →Userモデルの中では右式のselfを省略できる、左側のselfは省略することはできない
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  # ２つの連続したドットはマッチさせないようにする
  # →「foo@bar..com」のようなメールアドレスを許容しないように
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },

                    # メールのフォーマット(型)を決めている
                    # →なぜか…？文字列ならなんでもOKということを阻止するため
                    # →そうするには、「正規表現」を使用したほうがいいよね！
                    # →上で、正規表現を定義して変数に入れている
                    # ↓で、変数を引数にすることで可読性がよくなるよね！
                    format: { with: VALID_EMAIL_REGEX },

                    # uniqueness: true, ↓このままでは一意性(重複しているメアド)検証では
                    # 大文字小文字で「区別はされている」が
                    # 同じメールアドレス(同じ並び)が複製可能となっている
                    uniqueness: { case_sensitive: false }

  # DBにレコード(オブジェクト)が生成された時だけ存在性(nilかどうか)のvalidationを行う
  # →実際にpasswordを作成する際は、nilかどうかの検証を行ってくれる
  # →実行環境でpasswordが空だった場合のvalidation機能を保持したまま、
  # テストで空だった場合にvalidationを通すことができる
  has_secure_password

  # validates :password, presence: true, length: { minimum: 6 }
  # で、パスワードの最小文字数とかも設定(6章)

  # テストでは、名前とemailだけで更新できるようにしている
  # →しかし、allow_nil: true
  # パスワードが空のままでも更新できるようにする、空だった時の例外処理を加える

  # validates :password, presence: true, length: { minimum: 6 }のままでは
  # パスワードが空ですよと怒られてしまうため、「allow_nil」を追加する
  # passwordが空だったとしたらvalidationをスルー(true)する例外処理

  # allow_nilのおかげでhas_secure_passwordによるバリデーションがそれぞれ実行され、
  # 二つのエラーメッセージが表示されるバグも解決
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
  # アカウント有効化のダイジェストと、渡されたトークンが一致するかどうかをチェック
  # def authenticated?(remember_token)
  #   # 「user_test.rb」test "authenticated? should return~"をクリアさせる
  #   # 記憶ダイジェストがnilの場合にfalseを返す
  #   # 記憶ダイジェストがnilの場合、returnでfalseを返すことで、即座にメソッドを終了している

  #   # →処理を中途で終了する場合によく使われる使いかた
  #   # return false if remember_digest.nil?
  #   # BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # 各引数を一般化し、文字列の式展開も利用する↑
  def authenticated?(attribute, token)
    # モデル内にあるのでselfは省略することもできる
    # digest = self.send("#{attribute}_digest")
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  # user.remember「上にあるユーザーを覚えるメソッド」が取り消され
  def forget
    # DBにある記憶ダイジェストをnilにする
    update_attribute(:remember_digest, nil)
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    # ハッシュ化した記憶トークンを有効化トークン属性に代入
    self.activation_token  = User.new_token
    # 有効化トークンをBcryptで暗号化し、有効化ダイジェスト属性に代入
    self.activation_digest = User.digest(activation_token)
  end

  # アカウントを有効にする
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    # 変更↓
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  # メールアドレスを全て小文字にする
  def downcase_email
    # emailを小文字化してUserオブジェクトのemail属性に代入
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    # ハッシュ化した記憶トークンを有効化トークン属性に代入
    self.activation_token = User.new_token
    # 有効化トークンをBcryptで暗号化し、有効化ダイジェスト属性に代入
    self.activation_digest  =   User.digest(activation_token)
  end
end
