import Foundation

let MutlipartFormCRLFData = toData("\r\n")

func encode(string: String) -> String {
  let characterSet = NSCharacterSet.MIMECharacterSet()
  return string.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
}

func toData(string: String) -> NSData {
  return string.dataUsingEncoding(NSUTF8StringEncoding)!
}

func merge(chunks: [NSData]) -> NSData {
  let data = NSMutableData()
  chunks.forEach { data.appendData($0) }
  return data.copy() as! NSData
}
