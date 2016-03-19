import Foundation

private let streamBufferSize = 1024

enum StreamError: ErrorType {
  case InputStreamReadFailed
  case OutputStreamWriteFailed
}

struct MultipartInputStream {

  let chunks: [MultipartDataChunk]
  let output: NSOutputStream
  
  private let fieldBoundary: NSData
  private let edgeBoundary: NSData

  init?(filePath: String, boundary: String, chunks: [MultipartDataChunk]) {
    self.chunks = chunks
    self.fieldBoundary = toData("--\(boundary)\r\n")
    self.edgeBoundary = toData("--\(boundary)--\r\n")
    if let output = NSOutputStream(toFileAtPath: filePath, append: false) {
      self.output = output
    } else {
      return nil
    }
  }

  func write() throws {
    self.output.open()
    try self.chunks.forEach({ try self.writeChunk($0) })
    try self.writeStream(NSInputStream(data: self.edgeBoundary))
    self.output.close()
  }

  func writeChunk(chunk: MultipartDataChunk) throws {
    try self.writeStream(NSInputStream(data: self.fieldBoundary))
    try chunk.stream().forEach({ try self.writeStream($0) })
  }

  private func writeStream(stream: NSInputStream) throws {
    stream.open()
    defer { stream.close() }

    while stream.hasBytesAvailable {
      var buffer = [UInt8](count: streamBufferSize, repeatedValue: 0)
      let bytesRead = stream.read(&buffer, maxLength: streamBufferSize)

      if let streamError = stream.streamError {
        debugPrint("Input stream failed: \(streamError)")
        throw streamError
      }

      if bytesRead > 0 && buffer.count != bytesRead {
        buffer = Array(buffer[0..<bytesRead])
        let _ = try self.writeBuffer(&buffer, toOutputStream: self.output)
      } else if bytesRead < 0 {
        debugPrint("Failed to read from input stream")
        throw StreamError.InputStreamReadFailed
      } else {
        break
      }
    }
  }

  private func writeBuffer(inout buffer: [UInt8], toOutputStream outputStream: NSOutputStream) throws {
    var bytesToWrite = buffer.count

    while bytesToWrite > 0 {
      if outputStream.hasSpaceAvailable {
        let bytesWritten = outputStream.write(buffer, maxLength: bytesToWrite)

        if let streamError = outputStream.streamError {
          throw streamError
        }

        if bytesWritten < 0 {
          debugPrint("failed to write to output stream")
          throw StreamError.OutputStreamWriteFailed
        }

        bytesToWrite -= bytesWritten

        if bytesToWrite > 0 {
          buffer = Array(buffer[bytesWritten..<buffer.count])
        }
      } else if let streamError = outputStream.streamError {
        throw streamError
      }
    }
  }

}
