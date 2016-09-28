import Foundation

extension CharacterSet {

  static func MIMECharacterSet() -> CharacterSet {
    let characterSet = CharacterSet(charactersIn: "\"\n\r")
    return characterSet.inverted
  }
  
}
