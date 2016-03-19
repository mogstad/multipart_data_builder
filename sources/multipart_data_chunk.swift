import Foundation

enum MultipartDataChunk {
  case Stream(name: String, content: NSInputStream, fileName: String, contentType: String)
  case Data(name: String, content: NSData, fileName: String, contentType: String)
  case Field(key: String, value: String)

  func stream() -> [NSInputStream] {
    switch self {
    case let .Data(name, content, fileName, contentType):
      let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(name))\"; filename=\"\(encode(fileName))\""
      let contentTypeHeader = "Content-Type: \(contentType)"
      let data = merge([
        toData(contentDisposition),
        MutlipartFormCRLFData,
        toData(contentTypeHeader),
        MutlipartFormCRLFData,
        MutlipartFormCRLFData,
        content,
        MutlipartFormCRLFData
      ])
      return [NSInputStream(data: data)]
    case let .Field(key, value):
      let content = "Content-Disposition: form-data; name=\"\(encode(key))\""
      let data = merge([
        toData(content),
        MutlipartFormCRLFData,
        MutlipartFormCRLFData,
        toData(value),
        MutlipartFormCRLFData
      ])
      return [NSInputStream(data: data)]
    case let .Stream(name, content, fileName, contentType):
      let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(name))\"; filename=\"\(encode(fileName))\""
      let contentTypeHeader = "Content-Type: \(contentType)"
      let prologue = merge([
        toData(contentDisposition),
        MutlipartFormCRLFData,
        toData(contentTypeHeader),
        MutlipartFormCRLFData,
        MutlipartFormCRLFData,
      ])
      
      return [
        NSInputStream(data: prologue),
        content,
        NSInputStream(data: MutlipartFormCRLFData)
      ]
    }
  }

}
