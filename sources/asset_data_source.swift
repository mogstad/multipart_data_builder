import Foundation
import MobileCoreServices
import Photos

class AssetDataSource: ChunkDataSource {

  let source: PHAsset
  let key: String
  let asset: PHAssetResource?
  var request: PHAssetResourceDataRequestID?

  init(key: String, source: PHAsset) {
    self.source = source
    self.key = key
    let assets = PHAssetResource.assetResourcesForAsset(source)
    let index = assets.indexOf { asset -> Bool in
      let primaryType = asset.type == .Video || asset.type == .Photo || asset.type == .Audio
      return primaryType
    }
    if let index = index {
      self.asset = assets[index]
    } else {
      self.asset = nil
    }
  }

  func write(outputStream: NSOutputStream, completeHandler: AssetDataSourceCompleteHandler) {
    guard let asset = self.asset else {
      return completeHandler(nil)
    }
    do {
      try self.writePrologue(asset, outputStream: outputStream)
    } catch {
      return completeHandler(error)
    }

    self.request = PHAssetResourceManager.defaultManager().requestDataForAssetResource(asset,
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
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(self.key))\"; filename=\"\(encode(resource.originalFilename))\""
    let contentType: String
    if let mimeType = UTTypeCopyPreferredTagWithClass(resource.uniformTypeIdentifier, kUTTagClassMIMEType) {
      contentType = mimeType.takeRetainedValue() as String
    } else {
      contentType = "application/octet-stream"
    }

    let contentTypeHeader = "Content-Type: \(contentType)"
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
