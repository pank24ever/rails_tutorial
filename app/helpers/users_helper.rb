module UsersHelper
  # 引数で与えられたユーザーのGravatar画像を返す
  # APIを使用している
  def gravatar_for(user, options = { size: 80 })
    #小文字化したuserメールをMD5でハッシュ化し、変数に代入
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    #gravatarのURLに変数展開,画像用の変数に代入
    # gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    # ↓sizeをオプション引数として受け取れるようにする

    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    #画像を表示し、user.nameを画像が表示されない時用に、classにgravatarを指定
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
