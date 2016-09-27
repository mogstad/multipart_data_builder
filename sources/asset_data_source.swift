import Foundation
import MobileCoreServices
import Photos

func contentTypeForUTI(UTI: String) -> String {
  if let mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) {
    return mimeType.takeRetainedValue() as String
  }
  return "application/octet-stream"
}

class AssetDataSource: ChunkDataSource {

  enum Error: ErrorType {
    case NoExportSession
    case ExportSessionFailed
    case NoImageData
    case NoImageUTI
    case NoResourceAsset
    case UnknownMediaType
  }

  let name: String
  let asset: PHAsset
  var request: PHAssetResourceDataRequestID?

  init(name: String, asset: PHAsset) {
    self.asset = asset
    self.name = name
  }

  func write(outputStream: NSOutputStream, completeHandler: AssetDataSourceCompleteHandler) {
    let manager = PHImageManager.defaultManager()
    switch self.asset.mediaType {
    case .Video:

      let options = PHVideoRequestOptions()
      options.networkAccessAllowed = true
      manager.requestExportSessionForVideo(self.asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { (exportSession, info) in
        guard let exportSession = exportSession else {
          return completeHandler(Error.NoExportSession)
        }

        let fileType = AVFileTypeQuickTimeMovie
        exportSession.outputFileType = fileType
        let date = NSDate().timeIntervalSince1970
        let outputURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("temp-\(date).mov")
        if NSFileManager.defaultManager().fileExistsAtPath(outputURL!.path!) {
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(outputURL!)
        }
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronouslyWithCompletionHandler({ 

          guard case AVAssetExportSessionStatus.Completed = exportSession.status else {
            return completeHandler(Error.ExportSessionFailed)
          }

          let inputStream = NSInputStream(URL: outputURL!)!
          do {
            try self.writePrologue(self.asset, contentType: contentTypeForUTI(fileType), outputStream: outputStream)
            try self.writeStream(inputStream, outputStream: outputStream)
            try self.writeData(MutlipartFormCRLFData, outputStream: outputStream)
            completeHandler(nil)
          } catch {
            completeHandler(error)
          }
        })
      }
    case .Image:
      let options = PHImageRequestOptions()
      options.networkAccessAllowed = true
      self.request = manager.requestImageDataForAsset(self.asset, options: options) { (data, uti, orientation, info) in
        guard let data = data else {
          return completeHandler(Error.NoImageData)
        }

        guard let uti = uti else {
          return completeHandler(Error.NoImageUTI)
        }

        do {
          try self.writePrologue(self.asset, contentType: contentTypeForUTI(uti), outputStream: outputStream)
          try self.writeData(data, outputStream: outputStream)
          try self.writeData(MutlipartFormCRLFData, outputStream: outputStream)
          completeHandler(nil)
        } catch {
          completeHandler(error)
        }
      }
    default:
      completeHandler(Error.UnknownMediaType)
    }
  }

  func cancel() {
    if let request = self.request {
      PHAssetResourceManager.defaultManager().cancelDataRequest(request)
    }
  }

  private func writePrologue(asset: PHAsset, contentType: String, outputStream: NSOutputStream) throws {
    let resources = PHAssetResource.assetResourcesForAsset(asset)
    guard let resource = primaryAssetResource(resources) else { throw Error.NoResourceAsset }
    let contentDisposition = "Content-Disposition: form-data; name=\"\(encode(self.name))\"; filename=\"\(encode(resource.originalFilename))\""

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

  private func writeStream(inputStream: NSInputStream, outputStream: NSOutputStream) throws {
    try readStream(inputStream) { buffer in
      try writeBuffer(buffer, toOutputStream: outputStream)
    }
  }
}
