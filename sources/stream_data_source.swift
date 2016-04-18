import Foundation

private let streamBufferSize = 1024

class StreamDataSource: ChunkDataSource {

  let streams: [NSInputStream]

  init(streams: [NSInputStream]) {
    self.streams = streams
  }

  func write(outputStream: NSOutputStream, completeHandler: AssetDataSourceCompleteHandler) {
    do {
      try self.streams.forEach({ try self.writeStream($0, outputStream: outputStream) })
      completeHandler(nil)
    } catch {
      completeHandler(error)
    }
  }

  // MARK: Private

  private func writeStream(inputStream: NSInputStream, outputStream: NSOutputStream) throws {
    try readStream(inputStream) { buffer in
      try writeBuffer(buffer, toOutputStream: outputStream)
    }
  }

}
