import Photos
import MobileCoreServices

func contentTypeForResource(resource: PHAssetResource) -> String {
  if let mimeType = UTTypeCopyPreferredTagWithClass(resource.uniformTypeIdentifier, kUTTagClassMIMEType) {
    return mimeType.takeRetainedValue() as String
  }
  return "application/octet-stream"
}

func primaryAsset(resources: [PHAssetResource]) -> PHAssetResource? {
  let index = resources.indexOf { resource -> Bool in
    let primaryType = resource.type == .Video || resource.type == .Photo || resource.type == .Audio
    return primaryType
  }
  guard let assetIndex = index else { return nil }
  return resources[assetIndex]
}

public struct MultipartAssetField: MultipartField {

  public let asset: PHAssetResource
  public let name: String
  public let contentType: String

  public init?(name: String, asset: PHAsset) {
    let assets = PHAssetResource.assetResourcesForAsset(asset)
    guard let asset = primaryAsset(assets) else { return nil }

    self.name = name
    self.asset = asset
    self.contentType = contentTypeForResource(asset)
  }

  public func dataSource() -> ChunkDataSource {
    return AssetDataSource(
      name: self.name,
      contentType: self.contentType,
      asset: self.asset)
  }

}
