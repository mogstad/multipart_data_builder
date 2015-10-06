import Foundation

extension NSCharacterSet {

  class func MIMECharacterSet() -> NSCharacterSet {
    let characterSet = NSCharacterSet(charactersInString: "\"\n\r")
    return characterSet.invertedSet
  }
  
}
