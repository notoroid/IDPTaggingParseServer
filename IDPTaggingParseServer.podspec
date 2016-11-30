Pod::Spec.new do |s|

  s.name         = "IDPTaggingParseServer"
  s.version      = "0.0.1"
  s.summary      = "IDPTaggingParseServer is middleware that adds tagging to objects and search by tags. IDPTaggingParseServer is built on the server side as ParseServer and client side as Objective-C."

  s.description  = <<-DESC
                   IDPTaggingParseServer is middleware that adds tagging to objects and search by tags. IDPTaggingParseServer is built on the server side as ParseServer and client side as Objective-C. - IDPTaggingParseServer はオブジェクトへのタグ付け及びタグによる検索を付加するミドルウェアです。IDPTaggingParseServer はサーバーサイドはParseServer 、クライアントサイドはObjective-Cで構築されています。
                   DESC

  s.homepage     = "https://github.com/notoroid/IDPTaggingParseServer"

  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "notoroid" => "noto@irimasu.com" }
  s.social_media_url   = "http://twitter.com/notoroid"

  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/notoroid/IDPcompositePixStorage.git", :tag => "v#{s.version}" }
  s.source_files  = "Lib/**/*.{h,m}","Lib/IDPStorageManagerModel.xcdatamodeld","Lib/IDPStorageManagerModel.xcdatamodeld/*.xcdatamodel"
  s.resources  = "Lib/**/*.{storyboard,xib}"
  s.dependency 'Parse'
  s.dependency 'Bolts'
  s.dependency 'UICollectionViewLeftAlignedLayout'

  s.requires_arc = true

end
