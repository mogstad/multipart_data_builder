import Foundation

private let streamBufferSize = 1024

class StreamDataSource: ChunkDataSource {

  let streams: [InputStream]

  init(streams: [InputStream]) {
    self.streams = streams
  }

  func write(_ outputStream: OutputStream, completeHandler: @escaping AssetDataSourceCompleteHandler) {
    do {
      try self.streams.forEach({ try self.writeStream($0, outputStream: outputStream) })
      completeHandler(nil)
    } catch {
      completeHandler(error)
    }
  }

  // MARK: Private

  fileprivate func writeStream(_ inputStream: InputStream, outputStream: OutputStream) throws {
    try readStream(inputStream) { buffer in
      try writeBuffer(buffer, toOutputStream: outputStream)
    }
  }

}
