import Photos
import MobileCoreServices

func primaryAssetResource(_ resources: [PHAssetResource]) -> PHAssetResource? {
  let index = resources.index { resource -> Bool in
    let primaryType = resource.type == .video || resource.type == .photo || resource.type == .audio
    return primaryType
  }
  guard let assetIndex = index else { return nil }
  return resources[assetIndex]
}

public struct MultipartAssetField: MultipartField {

  public let asset: PHAsset
  public let contentType: String
  public let name: String

  public init?(name: String, asset: PHAsset) {
    self.name = name
    self.asset = asset

    switch asset.mediaType {
    case .video:
      self.contentType = contentTypeForUTI(AVFileTypeQuickTimeMovie)
    case .image:
      let resources = PHAssetResource.assetResources(for: asset)
      guard let resource = primaryAssetResource(resources) else { return nil }
      self.contentType = contentTypeForUTI(resource.uniformTypeIdentifier)
    default:
      return nil
    }
  }

  public func dataSource() -> ChunkDataSource {
    return AssetDataSource(
      name: self.name,
      asset: self.asset)
  }

}
