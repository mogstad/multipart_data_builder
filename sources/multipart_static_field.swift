public struct MultipartStaticField: MultipartField {

  public let name: String
  public let value: String

  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }

  public func dataSource() -> ChunkDataSource {
    let content = "Content-Disposition: form-data; name=\"\(encode(self.name))\""
    let data = merge([
      toData(content),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData,
      toData(self.value),
      MutlipartFormCRLFData
    ])
    return StreamDataSource(streams: [InputStream(data: data)])
  }
  
}
