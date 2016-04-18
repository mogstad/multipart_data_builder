import Foundation

private let streamBufferSize = 4096

enum InputStreamError: ErrorType {
  case ReadError
}

func readStream(stream: NSInputStream, read: (buffer: [UInt8]) throws -> Void) throws {
  stream.open()
  defer { stream.close() }

  while stream.hasBytesAvailable {
    var buffer = Array<UInt8>(count: streamBufferSize, repeatedValue: 0)
    let bytesRead = stream.read(&buffer, maxLength: streamBufferSize)
    if bytesRead < 0 {
      throw InputStreamError.ReadError
    }

    if let streamError = stream.streamError {
      throw streamError
    }

    if buffer.count != bytesRead {
      buffer = Array(buffer[0..<bytesRead])
    }

    try read(buffer: buffer)
  }
}
