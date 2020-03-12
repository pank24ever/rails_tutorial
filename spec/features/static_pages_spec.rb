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

# describe '四則計算' do
#   # テストを example という単位にまとめる役割
#   it '1+1は2になる' do
#     expect(1+1).to eq 2
#   end
# end

require 'rails_helper'

RSpec.describe 'Access to static_pages', type: :request do
  # describeとほぼ同じ
  # →条件別にグループ化したい場合に使う
  context 'GET #home' do
    before { get root_path }
    it 'responds successfully' do
      expect(response).to have_http_status 200
    end
    it "has title 'Ruby on Rails Tutorial Sample App'" do
      expect(response.body).to include 'Ruby on Rails Tutorial Sample App'
      expect(response.body).to_not include '| Ruby on Rails Tutorial Sample App'
    end
  end
  context 'GET #help' do
    before { get help_path }
    it 'responds successfully' do
      expect(response).to have_http_status 200
    end
    it "has title 'Home | Ruby on Rails Tutorial Sample App'" do
      expect(response.body).to include 'Help | Ruby on Rails Tutorial Sample App'
    end
  end
  context 'GET #about' do
    before { get about_path }
    it 'responds successfully' do
      expect(response).to have_http_status 200
    end
    it "has title 'Home | Ruby on Rails Tutorial Sample App'" do
      expect(response.body).to include 'About | Ruby on Rails Tutorial Sample App'
    end
  end
end
