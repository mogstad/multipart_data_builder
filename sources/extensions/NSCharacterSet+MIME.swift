import Foundation

extension NSCharacterSet {

  class func MIMECharacterSet() -> NSCharacterSet {
    let characterSet = NSCharacterSet(charactersIn: "\"\n\r")
    return characterSet.inverted as NSCharacterSet
  }
  
}
