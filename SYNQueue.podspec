
Pod::Spec.new do |s|
  s.name             = "SYNQueue"
  s.version          = "0.1.0"
  s.summary          = ""
  s.description      = ""
  s.homepage         = "https://github.com/Syntertainment/SYNQueue"
  s.license          = 'MIT'
  s.author           = { "John Hurliman" => "johnh@thredhq.com", "Sidhant Gandhi" => "sidhantg@thredhq.com" }
  s.source           = { :git => "https://github.com/Syntertainment/SYNQueue.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.public_header_files = ["SYNQueue/SYNQueue/SYNQueue.h"]
  s.source_files = 'SYNQueue/SYNQueue/**.swift'
end
