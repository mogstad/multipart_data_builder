# Multipart Data Builder

[![Build Status](https://img.shields.io/circleci/project/mogstad/multipart_data_builder.svg?style=flat-square)](https://circleci.com/gh/mogstad/multipart_data_builder)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/MultipartDataBuilder.svg?style=flat-square)](https://cocoapods.org/pods/MultipartDataBuilder)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)

MultipartDataBuilder is a micro framework for creating multipart data forms, used for uploading files over HTTP.

## Usage

MultipartDataBuilder provides a simple API for building fields, and an extension on `NSMutableURLRequest` for attaching the built form and sets the required header.

#### Creating the multipart form:

```swift
var builder = MultipartDataBuilder()
```
#### Posting a file:

```swift
builder.appendFormData("image",
  content: image,
  fileName: "photo.jpg",
  contentType: "image/jpeg")
```

#### Adding other form data:

```swift
builder.appendFormData("filter", value: "sepia")
```

#### Building the form:

```swift
request.setMultipartBody(builder.build(), boundary: builder.boundary)
```

## Install

### [Carthage](https://github.com/carthage/carthage)

1. Add `github "mogstad/multipart_data_builder" ~> 2.0` to your “Cartfile”
2. Run `carthage update`
3. Link MultipartDataBuilder with your target
4. Create a new “Copy files” build phases, set ”Destination” to ”Frameworks”, add MultipartDataBuilder

### [CocoaPods](https://cocoapods.org)

Update your podfile:

1. Add `use_frameworks!` to your pod file[^1]
2. Add `pod "MultipartDataBuilder", "~> 2.0"` to your target
3. Update your dependencies by running `pod install`

[^1]:
Swift code can’t be included as a static library, therefor it’s required to add `use_frameworks!` to your `podfile`. It will then import your dependeices as dynamic frameworks.
