import Foundation
import CryptoSwift

/// Effectively creates a MD5 hash of an input stream.
///
/// - parameter inputStream: Input stream
/// - returns: MD5 string of the content of the input stream
/// - throws: InputStreamError
public func createMD5String(_ inputStream: InputStream) throws -> String {
  var md5 = CryptoSwift.MD5()
  try readStream(inputStream) { buffer in
    _ = try md5.update(withBytes: buffer)
  }

  let digest = try md5.finish()
  let digestString = digest.reduce("", { all, chunk in
    return all.appendingFormat("%02x", chunk)
  })

  return digestString
}
