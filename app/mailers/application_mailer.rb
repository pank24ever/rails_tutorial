class ApplicationMailer < ActionMailer::Base
  # default from: 'from@example.com'↓カスタマイズ
  # fromアドレスのデフォルト値を更新したアプリケーションメイラー
  default from: "noreply@example.com"
  layout 'mailer'
end
