import Foundation

private let streamBufferSize = 4096

enum InputStreamError: Error {
  case readError
}

func readStream(_ stream: InputStream, read: (_ buffer: [UInt8]) throws -> Void) throws {
  stream.open()
  defer { stream.close() }

  while stream.hasBytesAvailable {
    var buffer = Array<UInt8>(repeating: 0, count: streamBufferSize)
    let bytesRead = stream.read(&buffer, maxLength: streamBufferSize)
    if bytesRead < 0 {
      throw InputStreamError.readError
    }

    if let streamError = stream.streamError {
      throw streamError
    }

    if buffer.count != bytesRead {
      buffer = Array(buffer[0..<bytesRead])
    }

    try read(buffer)
  }
}
