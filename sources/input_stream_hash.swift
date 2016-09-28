import Foundation
import CommonCrypto

/// Effectively creates a MD5 hash of an input stream.
///
/// - parameter inputStream: Input stream
/// - returns: MD5 string of the content of the input stream
/// - throws: InputStreamError
public func createMD5String(_ inputStream: InputStream) throws -> String {
  var context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: MemoryLayout<CC_MD5_CTX>.size)
  defer { context.deinitialize() }

  CC_MD5_Init(context)
  try readStream(inputStream) { buffer in
    CC_MD5_Update(context, buffer, UInt32(buffer.count))
  }

  let digestLength = Int(CC_MD5_DIGEST_LENGTH) * MemoryLayout<UInt8>.size
  var digest = Array<UInt8>(repeating: 0, count: digestLength)
  CC_MD5_Final(&digest, context)

  let digestString = digest.reduce("", { all, chunk in
    return all.appendingFormat("%02x", chunk)
  })

  return digestString
}
