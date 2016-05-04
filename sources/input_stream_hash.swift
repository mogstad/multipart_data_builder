import Foundation
import CommonCrypto

/// Effectively creates a MD5 hash of an input stream.
///
/// - parameter inputStream: Input stream
/// - returns: MD5 string of the content of the input stream
/// - throws: InputStreamError
public func createMD5String(inputStream: NSInputStream) throws -> String {
  var context = UnsafeMutablePointer<CC_MD5_CTX>.alloc(sizeof(CC_MD5_CTX))
  defer { context.destroy() }

  CC_MD5_Init(context)
  try readStream(inputStream) { buffer in
    CC_MD5_Update(context, buffer, UInt32(buffer.count))
  }

  let digestLength = Int(CC_MD5_DIGEST_LENGTH) * sizeof(UInt8)
  var digest = Array<UInt8>(count: digestLength, repeatedValue: 0)
  CC_MD5_Final(&digest, context)

  let digestString = digest.reduce("", combine: { all, chunk in
    return all.stringByAppendingFormat("%02x", chunk)
  })

  return digestString
}
