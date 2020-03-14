ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # テストユーザーがログイン中の場合にtrueを返す
  # テストのセッションにユーザーがあればtrueを返し、それ以外の場合はfalseを返します
  # sessions_helperに対してテストする4
  def is_logged_in?
    !session[:user_id].nil?
  end

  # ユーザーが記憶されるにはログインが必要
  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # 統合テストで扱うヘルパーなのでActionDispatch::IntegrationTestクラスの中で定義する

  # log_in_as(user)↑と同じように
  # 統合テストでも同じヘルパーを実装していく

  # 統合テストではsessionを直接取り扱うことができないので、
  # 代わりにSessionsリソースに対してpostを送信することで代用する↓

  # テストユーザーとしてログインする
  # ログイン時のユーザーとして、チェックボックスにチェックを入れてる(1)
  def log_in_as(user, password: 'password', remember_me: '1')
    # /login に対してparamsとしてsessionハッシュに各属性の値が入れて送信
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end
