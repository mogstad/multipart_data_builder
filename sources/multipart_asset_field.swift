import Photos
import MobileCoreServices

func primaryAssetResource(resources: [PHAssetResource]) -> PHAssetResource? {
  let index = resources.indexOf { resource -> Bool in
    let primaryType = resource.type == .Video || resource.type == .Photo || resource.type == .Audio
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
    case .Video:
      self.contentType = contentTypeForUTI(AVFileTypeQuickTimeMovie)
    case .Image:
      let resources = PHAssetResource.assetResourcesForAsset(asset)
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
