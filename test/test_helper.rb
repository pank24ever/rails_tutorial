ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

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
end
