Pod::Spec.new do |spec|
  spec.name = "MultipartDataBuilder"
  spec.version = "3.0.0-alpha5"
  spec.license = "MIT"
  spec.summary = "Micro framework for creating multipart forms"
  spec.homepage = "https://github.com/mogstad/multipart_data_builder"
  spec.authors = { 
    "Bjarne Mogstad" => "me@mogstad.co" 
  }
  spec.source = { 
    :git => "https://github.com/mogstad/multipart_data_builder.git", 
    :tag => "v3.0.0-alpha5"
  }
  spec.platforms = {
    :ios => "9.0"
  }
  spec.ios.frameworks = "MobileCoreServices"
  spec.dependencies = {
    "libCommonCrypto" => ["~> 0.1"]
  }
  spec.source_files = ["sources/**/*.swift", "supporting_files/MultipartDataBuilder.h"]
  spec.requires_arc = true
end
