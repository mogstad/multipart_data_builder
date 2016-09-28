import Foundation

private let streamBufferSize = 1024

enum StreamError: Error {
  case inputStreamReadFailed
  case outputStreamWriteFailed
}

struct MultipartFormBuilder {

  let fields: [MultipartField]
  let output: OutputStream
  
  fileprivate let fieldBoundary: Data
  fileprivate let edgeBoundary: Data

  init?(filePath: String, boundary: String, fields: [MultipartField]) {
    self.fields = fields
    self.fieldBoundary = toData("--\(boundary)\r\n")
    self.edgeBoundary = toData("--\(boundary)--\r\n")
    if let output = OutputStream(toFileAtPath: filePath, append: false) {
      self.output = output
    } else {
      return nil
    }
  }

  func write(_ complete: @escaping (Error?) -> Void) {
    self.output.open()
    var dataSources = self.fields.flatMap { field -> [ChunkDataSource] in
      return [
        StreamDataSource(streams: [InputStream(data: self.fieldBoundary)]),
        field.dataSource()
      ]
    }

    let edgeDataSource = StreamDataSource(streams: [InputStream(data: self.edgeBoundary)])
    dataSources.append(edgeDataSource)
    self.writeDataSource(dataSources, outputStream: self.output, complete: { error in
      complete(error)
      self.output.close()
    })
  }

  func writeDataSource(_ dataSources: [ChunkDataSource], outputStream: OutputStream, complete: @escaping (Error?) -> Void) {
    var dataSources = dataSources
    if let item = dataSources.first {
      dataSources.remove(at: 0)
      item.write(outputStream, completeHandler: { error in
        if let error = error {
          complete(error)
        } else {
          self.writeDataSource(dataSources, outputStream: outputStream, complete: complete)
        }
      })
    } else {
      complete(nil)
    }
  }

}
