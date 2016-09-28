import Foundation

/// MultipartForm builds a multipart form (RFC2388) form both key value
/// pairs and chunks of data as embedded files.

public struct MultipartForm {

  public let boundary: String
  fileprivate var fields: [MultipartField] = []

  public init() {
    self.boundary = "com.getflow.multipart-data-builder.\(arc4random()).\(arc4random())"
  }

  /// Builds the multipart form
  ///
  /// - returns: the built form as NSData
  public func build(_ callback: @escaping (_ stream: InputStream, _ filePath: String) -> Void) {
    DispatchQueue.global(qos: .background).async {
      let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
      if let builder = MultipartFormBuilder(
        filePath: filePath,
        boundary: self.boundary,
        fields: self.fields)
      {
          builder.write() { error in
            if let _ = error {
              let _ = try? FileManager.default.removeItem(atPath: filePath)
            } else {
              DispatchQueue.main.async {
                if let stream = InputStream(fileAtPath: filePath) {
                  callback(stream, filePath)
                }
              }
            }
          }
      }
    }
  }

  mutating public func appendField(_ field: MultipartField) {
    self.fields.append(field)
  }

  /// Appends a value pair to the form
  ///
  /// - parameter name: the used form-data key
  /// - parameter value: the appended value to the form
  mutating public func appendFormData(_ name: String, value: String) {
    self.fields.append(MultipartStaticField(name: name, value: value))
  }

  /// Appends a stream of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter stream: the content as a stream
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(_ name: String, stream: InputStream, fileName: String, contentType: String) {
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
  mutating public func appendFormData(_ name: String, content: Data, fileName: String, contentType: String) {
    self.fields.append(MultipartStreamField(
      name: name,
      fileName: fileName,
      contentType: contentType,
      content: InputStream(data: content)))
  }

}
