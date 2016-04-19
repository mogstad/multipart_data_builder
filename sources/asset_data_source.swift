import Foundation
import MobileCoreServices
import Photos

class AssetDataSource: ChunkDataSource {

  let name: String
  let asset: PHAssetResource
  let contentType: String
  var request: PHAssetResourceDataRequestID?

  init(name: String, contentType: String, asset: PHAssetResource) {
    self.asset = asset
    self.contentType = contentType
    self.name = name
  }

  func write(outputStream: NSOutputStream, completeHandler: AssetDataSourceCompleteHandler) {
    do {
      try self.writePrologue(self.asset, outputStream: outputStream)
    } catch {
      return completeHandler(error)
    }

    self.request = PHAssetResourceManager.defaultManager().requestDataForAssetResource(self.asset,
      options: nil,
      dataReceivedHandler: { data in
        do {
          try self.writeData(data, outputStream: outputStream)
          try self.writeData(MutlipartFormCRLFData, outputStream: outputStream)
        } catch {
          completeHandler(error)
        }
      },
      completionHandler: { error in
        completeHandler(error)
    })
  }

  func cancel() {
    if let request = self.request {
      PHAssetResourceManager.defaultManager().cancelDataRequest(request)
    }
  }

  private func writePrologue(resource: PHAssetResource, outputStream: NSOutputStream) throws {
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(self.name))\"; filename=\"\(encode(resource.originalFilename))\""

    let contentTypeHeader = "Content-Type: \(self.contentType)"
    let prologue = merge([
      toData(contentDisposition),
      MutlipartFormCRLFData,
      toData(contentTypeHeader),
      MutlipartFormCRLFData,
      MutlipartFormCRLFData
    ])
    
    try self.writeData(prologue, outputStream: outputStream)
  }

  private func writeData(data: NSData, outputStream: NSOutputStream) throws {
    var buffer = Array<UInt8>(count: data.length / sizeof(UInt8), repeatedValue: 0)
    data.getBytes(&buffer, length: data.length * sizeof(UInt8))
    try writeBuffer(buffer, toOutputStream: outputStream)
  }

}
