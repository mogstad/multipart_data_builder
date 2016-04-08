Pod::Spec.new do |spec|
  spec.name = "MultipartDataBuilder"
  spec.version = "3.0.0-alpha1"
  spec.license = "MIT"
  spec.summary = "Micro framework for creating multipart forms"
  spec.homepage = "https://github.com/mogstad/multipart_data_builder"
  spec.authors = { "Bjarne Mogstad" => "me@mogstad.co" }
  spec.source = { 
    :git => "https://github.com/mogstad/multipart_data_builder.git", 
    :branch => "streams"
  }
  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.10"
  spec.source_files = "sources/**/*.swift"
  spec.requires_arc = true
end
