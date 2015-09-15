import Foundation

private let MultipartFormCRLF = "\r\n"
private let MutlipartFormCRLFData = MultipartFormCRLF.dataUsingEncoding(NSUTF8StringEncoding)!

/// MultipartDataBuilder builds a multipart form (RFC2388) form both key value 
/// pairs and chunks of data as embedded files.

public struct MultipartDataBuilder {

  var fields: [NSData] = []
  public let boundary: String

  public init() {
    self.boundary = "0xKhTmXbhgOuNdArY"
  }

  /// Builds the multipart form
  /// 
  /// - returns: the built form as NSData
  public func build() -> NSData? {

    let data = NSMutableData()

    for field in self.fields {
      data.appendData(self.toData("--\(self.boundary)"))
      data.appendData(MutlipartFormCRLFData)
      data.appendData(field)
    }

    data.appendData(self.toData("--\(self.boundary)--"))
    data.appendData(MutlipartFormCRLFData)

    return (data.copy() as! NSData)
  }

  /// Appends a value pair to the form
  ///
  /// - parameter key: the used form-data key
  /// - parameter value: the appended value to the form
  mutating public func appendFormData(key: String, value: String) {
    let content = "Content-Disposition: form-data; name=\"\(encode(key))\""
    let data = self.merge([
      self.toData(content),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData,
      self.toData(value),
      MutlipartFormCRLFData
    ])
    self.fields.append(data)
  }

  /// Appends a chunk of data as a file
  ///
  /// - parameter name: the name of the field to post it as
  /// - parameter content: the data chunk to embed in the form
  /// - parameter fileName: file name of the file
  /// - parameter contentType: MIME content type of the embedded file
  mutating public func appendFormData(name: String, content: NSData, fileName: String, contentType: String) {
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(name))\"; filename=\"\(encode(fileName))\""
    let contentTypeHeader = "Content-Type: \(contentType)"
    let data = self.merge([
      self.toData(contentDisposition),
      MutlipartFormCRLFData,
      self.toData(contentTypeHeader),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData,
      content,
      MutlipartFormCRLFData
    ])
    self.fields.append(data)
  }

  // MARK: Private

  private func encode(string: String) -> String {
    let characterSet = NSCharacterSet.MIMECharacterSet()
    return string.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
  }

  private func toData(string: String) -> NSData {
    return string.dataUsingEncoding(NSUTF8StringEncoding)!
  }

  private func merge(chunks: [NSData]) -> NSData {
    let data = NSMutableData()
    for chunk in chunks {
      data.appendData(chunk)
    }
    return data.copy() as! NSData
  }
  
}
