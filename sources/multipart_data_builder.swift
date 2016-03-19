import Foundation

/// MultipartDataBuilder builds a multipart form (RFC2388) form both key value
/// pairs and chunks of data as embedded files.

public struct MultipartDataBuilder {

  public let boundary: String
  private var chunks: [MultipartDataChunk] = []

  public init() {
    self.boundary = "com.getflow.multipart-data-builder.\(arc4random()).\(arc4random())"
  }

  /// Builds the multipart form
  ///
  /// - returns: the built form as NSData
  public func build(callback: (stream: NSInputStream, filePath: String) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSUUID().UUIDString)
      if let builder = MultipartInputStream(
        filePath: filePath,
        boundary: self.boundary,
        chunks: self.chunks)
      {
        do {
          try builder.write()
          dispatch_async(dispatch_get_main_queue()) {
            if let stream = NSInputStream(fileAtPath: filePath) {
              callback(stream: stream, filePath: filePath)
            }
          }
        } catch {
          debugPrint("failed: \(error)")
          let _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
        }
      }
    }

  }

  /// Appends a value pair to the form
  ///
  /// - parameter key: the used form-data key
  /// - parameter value: the appended value to the form
  mutating public func appendFormData(key: String, value: String) {
    self.chunks.append(.Field(key: key, value: value))
  }

  /// Appends a stream of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter stream: the content as a stream
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(name: String, stream: NSInputStream, fileName: String, contentType: String) {

    self.chunks.append(.Stream(
      name: name,
      content: stream,
      fileName: fileName,
      contentType: contentType))
  }

  /// Appends a chunk of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter content: the data chunk to embed in the form
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(name: String, content: NSData, fileName: String, contentType: String) {
    self.chunks.append(.Data(
      name: name,
      content: content,
      fileName: fileName,
      contentType: contentType))
  }

}
