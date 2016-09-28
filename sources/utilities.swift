import Foundation

let MutlipartFormCRLFData = toData("\r\n")

func encode(_ string: String) -> String {
  let characterSet = CharacterSet.MIMECharacterSet()
  return string.addingPercentEncoding(withAllowedCharacters: characterSet)!
}

func toData(_ string: String) -> Data {
  return string.data(using: String.Encoding.utf8)!
}

func merge(_ chunks: [Data]) -> Data {
  let data = NSMutableData()
  chunks.forEach { data.append($0) }
  return data.copy() as! Data
}
