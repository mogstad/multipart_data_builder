import Foundation

public typealias AssetDataSourceCompleteHandler = (Error?) -> Void

public protocol ChunkDataSource {
  func write(_ outputStream: OutputStream, completeHandler: @escaping AssetDataSourceCompleteHandler)
  func cancel()
}

extension ChunkDataSource {
  func cancel() { /* no-op */ }
}
