import Foundation

public extension NSMutableURLRequest {

  /// Convenience method to configure a multipart form on a request
  ///
  /// :param: data the multipart for as NSData
  /// :param: boundary the boundary used to build the form
  public func setMultipartBody(data: NSData, boundary: String) {
    self.HTTPBody = data
    self.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
  }

}
