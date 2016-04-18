import Foundation

public typealias AssetDataSourceCompleteHandler = (ErrorType?) -> Void

public protocol ChunkDataSource {
  func write(outputStream: NSOutputStream, completeHandler: AssetDataSourceCompleteHandler)
  func cancel()
}

extension ChunkDataSource {
  func cancel() { /* no-op */ }
}
