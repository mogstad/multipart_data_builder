import Foundation


import Foundation

public struct MultipartStreamField: MultipartField {

  public let name: String
  public let content: InputStream
  public let fileName: String
  public let contentType: String

  public init(name: String, fileName: String, contentType: String, content: InputStream) {
    self.name = name
    self.fileName = fileName
    self.contentType = contentType
    self.content = content
  }

  public func dataSource() -> ChunkDataSource {
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(self.name))\"; filename=\"\(encode(self.fileName))\""
    let contentTypeHeader = "Content-Type: \(self.contentType)"
    let prologue = merge([
      toData(contentDisposition),
      MutlipartFormCRLFData,
      toData(contentTypeHeader),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData,
    ])

    return StreamDataSource(streams: [
      InputStream(data: prologue),
      self.content,
      InputStream(data: MutlipartFormCRLFData)
    ])
  }
  
}
