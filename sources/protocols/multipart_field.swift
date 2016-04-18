public protocol MultipartField {
  var name: String { get }
  func dataSource() -> ChunkDataSource
}
