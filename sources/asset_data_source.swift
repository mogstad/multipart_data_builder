import Foundation
import MobileCoreServices
import Photos

func contentTypeForUTI(_ UTI: String) -> String {
  if let mimeType = UTTypeCopyPreferredTagWithClass(UTI as CFString, kUTTagClassMIMEType) {
    return mimeType.takeRetainedValue() as String
  }
  return "application/octet-stream"
}

class AssetDataSource: ChunkDataSource {

  enum Error: Swift.Error {
    case noExportSession
    case exportSessionFailed
    case noImageData
    case noImageUTI
    case noResourceAsset
    case unknownMediaType
  }

  let name: String
  let asset: PHAsset
  var request: PHAssetResourceDataRequestID?

  init(name: String, asset: PHAsset) {
    self.asset = asset
    self.name = name
  }

  func write(_ outputStream: OutputStream, completeHandler: @escaping AssetDataSourceCompleteHandler) {
    let manager = PHImageManager.default()
    switch self.asset.mediaType {
    case .video:

      let options = PHVideoRequestOptions()
      options.isNetworkAccessAllowed = true
      manager.requestExportSession(forVideo: self.asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { (exportSession, info) in
        guard let exportSession = exportSession else {
          return completeHandler(Error.noExportSession)
        }

        let fileType = AVFileTypeQuickTimeMovie
        exportSession.outputFileType = fileType
        let date = Date().timeIntervalSince1970
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp-\(date).mov")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            let _ = try? FileManager.default.removeItem(at: outputURL)
        }
        exportSession.outputURL = outputURL
        exportSession.exportAsynchronously(completionHandler: { 

          guard case AVAssetExportSessionStatus.completed = exportSession.status else {
            return completeHandler(Error.exportSessionFailed)
          }

          let inputStream = InputStream(url: outputURL)!
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
    case .image:
      let options = PHImageRequestOptions()
      options.isNetworkAccessAllowed = true
      self.request = manager.requestImageData(for: self.asset, options: options) { (data, uti, orientation, info) in
        guard let data = data else {
          return completeHandler(Error.noImageData)
        }

        guard let uti = uti else {
          return completeHandler(Error.noImageUTI)
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
      completeHandler(Error.unknownMediaType)
    }
  }

  func cancel() {
    if let request = self.request {
      PHAssetResourceManager.default().cancelDataRequest(request)
    }
  }

  fileprivate func writePrologue(_ asset: PHAsset, contentType: String, outputStream: OutputStream) throws {
    let resources = PHAssetResource.assetResources(for: asset)
    guard let resource = primaryAssetResource(resources) else { throw Error.noResourceAsset }
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

  fileprivate func writeData(_ data: Data, outputStream: OutputStream) throws {
    var buffer = Array<UInt8>(repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
    (data as NSData).getBytes(&buffer, length: data.count * MemoryLayout<UInt8>.size)
    try writeBuffer(buffer, toOutputStream: outputStream)
  }

  fileprivate func writeStream(_ inputStream: InputStream, outputStream: OutputStream) throws {
    try readStream(inputStream) { buffer in
      try writeBuffer(buffer, toOutputStream: outputStream)
    }
  }
}
