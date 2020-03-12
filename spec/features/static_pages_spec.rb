require 'rails_helper'

# # テストしたい対象を記載する
# describe 'Home' do
#   # テストしたい内容の詳細
#   specify '画面の表示' do
#     # 'URL'の部分に検証したい画面のURLを記載
#     visit '/'
#     「expect(page).to」はvisitしたカレントページを対象とするという意味

#     # 「have_css」テストの検証したい内容を計るためのメソッドで
#     # 「マッチャ」(マッチを計るため)と呼ばれるものの1つ
#     # expect(page).to have_css('h1', text: 'Sample App')

#     # have_titleもマッチャの1つ
#     expect(page). have_title 'Home|Ruby on Rails Tutorial Sample App'

#   end
# end

# Rspec.describe 'Access to static_pages',type: :request do

# end

# describe '四則計算' do
#   # テストを example という単位にまとめる役割
#   it '1+1は2になる' do
#     expect(1+1).to eq 2
#   end
# end

