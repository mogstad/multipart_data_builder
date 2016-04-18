import Foundation

private let streamBufferSize = 1024

enum StreamError: ErrorType {
  case InputStreamReadFailed
  case OutputStreamWriteFailed
}

struct MultipartFormBuilder {

  let fields: [MultipartField]
  let output: NSOutputStream
  
  private let fieldBoundary: NSData
  private let edgeBoundary: NSData

  init?(filePath: String, boundary: String, fields: [MultipartField]) {
    self.fields = fields
    self.fieldBoundary = toData("--\(boundary)\r\n")
    self.edgeBoundary = toData("--\(boundary)--\r\n")
    if let output = NSOutputStream(toFileAtPath: filePath, append: false) {
      self.output = output
    } else {
      return nil
    }
  }

  func write(complete: (ErrorType?) -> Void) {
    self.output.open()
    var dataSources = self.fields.flatMap { field -> [ChunkDataSource] in
      return [
        StreamDataSource(streams: [NSInputStream(data: self.fieldBoundary)]),
        field.dataSource()
      ]
    }

    let edgeDataSource = StreamDataSource(streams: [NSInputStream(data: self.edgeBoundary)])
    dataSources.append(edgeDataSource)
    self.writeDataSource(dataSources, outputStream: self.output, complete: { error in
      complete(error)
      self.output.close()
    })
  }

  func writeDataSource(dataSources: [ChunkDataSource], outputStream: NSOutputStream, complete: (ErrorType?) -> Void) {
    var dataSources = dataSources
    if let item = dataSources.first {
      dataSources.removeAtIndex(0)
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
