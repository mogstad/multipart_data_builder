import Foundation

/// MultipartForm builds a multipart form (RFC2388) form both key value
/// pairs and chunks of data as embedded files.

public struct MultipartForm {

  public let boundary: String
  private var fields: [MultipartField] = []

  public init() {
    self.boundary = "com.getflow.multipart-data-builder.\(arc4random()).\(arc4random())"
  }

  /// Builds the multipart form
  ///
  /// - returns: the built form as NSData
  public func build(callback: (stream: NSInputStream, filePath: String) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSUUID().UUIDString)
      if let builder = MultipartFormBuilder(
        filePath: filePath,
        boundary: self.boundary,
        fields: self.fields)
      {
          builder.write() { error in
            if let _ = error {
              let _ = try? NSFileManager.defaultManager().removeItemAtPath(filePath)
            } else {
              dispatch_async(dispatch_get_main_queue()) {
                if let stream = NSInputStream(fileAtPath: filePath) {
                  callback(stream: stream, filePath: filePath)
                }
              }
            }
          }
      }
    }
  }

  mutating public func appendField(field: MultipartField) {
    self.fields.append(field)
  }

  /// Appends a value pair to the form
  ///
  /// - parameter name: the used form-data key
  /// - parameter value: the appended value to the form
  mutating public func appendFormData(name: String, value: String) {
    self.fields.append(MultipartStaticField(name: name, value: value))
  }

  /// Appends a stream of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter stream: the content as a stream
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(name: String, stream: NSInputStream, fileName: String, contentType: String) {
    self.fields.append(MultipartStreamField(
      name: name,
      fileName: fileName,
      contentType: contentType,
      content: stream))
  }

  /// Appends a chunk of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter content: the data chunk to embed in the form
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(name: String, content: NSData, fileName: String, contentType: String) {
    self.fields.append(MultipartStreamField(
      name: name,
      fileName: fileName,
      contentType: contentType,
      content: NSInputStream(data: content)))
  }

}
