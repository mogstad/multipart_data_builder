import Foundation

private let MultipartFormCRLF = "\r\n"
private let MutlipartFormCRLFData = MultipartFormCRLF.data(using: String.Encoding.utf8)!

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
      data.append(self.toData(string: "--\(self.boundary)") as Data)
      data.append(MutlipartFormCRLFData)
      data.append(field as Data)
    }

    data.append(self.toData(string: "--\(self.boundary)--") as Data)
    data.append(MutlipartFormCRLFData)

    return (data.copy() as! NSData)
  }

  /// Appends a value pair to the form
  ///
  /// - parameter key: the used form-data key
  /// - parameter value: the appended value to the form
  mutating public func appendFormData(key: String, value: String) {
    let content = "Content-Disposition: form-data; name=\"\(encode(string: key))\""
    let data = self.merge(chunks: [
      self.toData(string: content),
      MutlipartFormCRLFData as NSData,
      MutlipartFormCRLFData as NSData,
      self.toData(string: value),
      MutlipartFormCRLFData as NSData
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
    let contentDisposition = "Content-Disposition: form-data; name=\"\(self.encode(string: name))\"; filename=\"\(self.encode(string: fileName))\""
    let contentTypeHeader = "Content-Type: \(contentType)"
    let data = self.merge(chunks: [
      self.toData(string: contentDisposition),
      MutlipartFormCRLFData as NSData,
      self.toData(string: contentTypeHeader),
      MutlipartFormCRLFData as NSData,
      MutlipartFormCRLFData as NSData,
      content,
      MutlipartFormCRLFData as NSData
    ])
    self.fields.append(data)
  }

  // MARK: Private

  private func encode(string: String) -> String {
    let characterSet = NSCharacterSet.MIMECharacterSet()
	return string.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)!
  }

  private func toData(string: String) -> NSData {
    return string.data(using: String.Encoding.utf8)! as NSData
  }

  private func merge(chunks: [NSData]) -> NSData {
    let data = NSMutableData()
    for chunk in chunks {
      data.append(chunk as Data)
    }
    return data.copy() as! NSData
  }
  
}
