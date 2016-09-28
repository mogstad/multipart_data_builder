import Foundation
import Quick
import Nimble
import MultipartDataBuilder

func loadFile(_ path: String) -> String {
  return try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
}

func loadFixture(_ name: String, ofType type: String) -> Data {
  let bundle = Bundle(identifier: "com.getflow.tests")
  print(bundle?.bundlePath)
  return (try! Data(contentsOf: URL(fileURLWithPath: bundle!.path(forResource: name, ofType: type)!)))
}


class MultipartFormSpec: QuickSpec {

  override func spec() {

    var builder: MultipartForm!
    beforeEach {
      builder = MultipartForm()
    }

    it("serializes form field") {
      builder.appendFormData("target", value: "Walter White")
      let wanted = "--\(builder.boundary)\r\n" +
        "Content-Disposition: form-data; name=\"target\"\r\n\r\n" +
        "Walter White\r\n" +
      "--\(builder.boundary)--\r\n"

      waitUntil(action: { done in
        builder.build({ stream, filePath in
          expect(loadFile(filePath)).to(equal(wanted))
          done()
        })
      })
    }

    it("serializes multiple form fields") {
      builder.appendFormData("target", value: "Walter White")
      builder.appendFormData("action", value: "kill")

      let wanted = "--\(builder.boundary)\r\n" +
        "Content-Disposition: form-data; name=\"target\"\r\n\r\n" +
        "Walter White\r\n" +
        "--\(builder.boundary)\r\n" +
        "Content-Disposition: form-data; name=\"action\"\r\n\r\n" +
        "kill\r\n" +
        "--\(builder.boundary)--\r\n"

      waitUntil(action: { done in
        builder.build({ stream, filePath in
          expect(loadFile(filePath)).to(equal(wanted))
          done()
        })
      })
    }

    describe("raw data") {
      beforeEach {
        builder.appendFormData("file",
          content: loadFixture("text", ofType: "txt"),
          fileName: "text.txt",
          contentType: "plain/text")
      }

      it("works") {
        let wanted = "--\(builder.boundary)\r\n" +
          "Content-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\n" +
          "Content-Type: plain/text\r\n\r\n" +
          "Lorem ipsum\n\r\n" +
          "--\(builder.boundary)--\r\n"

        waitUntil(action: { done in
          builder.build({ stream, filePath in
            expect(loadFile(filePath)).to(equal(wanted))
            done()
          })
        })
      }
    }

    describe("streams of data") {

      beforeEach {
        let bundle = Bundle(identifier: "com.getflow.tests")!
        let path = bundle.path(forResource: "text", ofType: "txt")!
        let stream = InputStream(fileAtPath: path)!
        builder.appendFormData("file",
          stream: stream,
          fileName: "text.txt",
          contentType: "plain/text")
      }

      it("works") {
        let wanted = "--\(builder.boundary)\r\n" +
          "Content-Disposition: form-data; name=\"file\"; filename=\"text.txt\"\r\n" +
          "Content-Type: plain/text\r\n\r\n" +
          "Lorem ipsum\n\r\n" +
          "--\(builder.boundary)--\r\n"

        waitUntil(action: { done in
          builder.build({ stream, filePath in
            expect(loadFile(filePath)).to(equal(wanted))
            done()
          })
        })
      }
    }

  }

}
