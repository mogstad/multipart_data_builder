import Foundation

public struct MultipartDataField: MultipartField {

  public let name: String
  public let content: NSData
  public let fileName: String
  public let contentType: String

  public init(name: String, fileName: String, contentType: String, content: NSData) {
    self.name = name
    self.fileName = fileName
    self.contentType = contentType
    self.content = content
  }

  public func dataSource() -> ChunkDataSource {
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(self.name))\"; filename=\"\(encode(self.fileName))\""
    let contentTypeHeader = "Content-Type: \(self.contentType)"
    let data = merge([
      toData(contentDisposition),
      MutlipartFormCRLFData,
      toData(contentTypeHeader),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData,
      self.content,
      MutlipartFormCRLFData
    ])
    return StreamDataSource(streams: [NSInputStream(data: data)])
  }
  
}
