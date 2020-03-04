class User < ApplicationRecord
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
end
