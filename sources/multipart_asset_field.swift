import Photos

public struct MultipartAssetField: MultipartField {

  public let name: String
  let asset: PHAsset
  
  public init(name: String, asset: PHAsset) {
    self.name = name
    self.asset = asset
  }

  public func dataSource() -> ChunkDataSource {
    return AssetDataSource(key: self.name, source: self.asset)
  }

}
