import Foundation
import Quick
import Nimble
@testable import MultipartDataBuilder

func loadFile(path: String) -> String {
  return try! NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
}

func loadFixture(name: String, ofType type: String) -> NSData {
  let bundle = NSBundle(identifier: "com.getflow.tests")
  return NSData(contentsOfFile: bundle!.pathForResource(name, ofType: type)!)!
}

class MultipartDataBuilderSpec: QuickSpec {

  override func spec() {

    var builder: MultipartDataBuilder!
    beforeEach {
      builder = MultipartDataBuilder()
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

      fit("works") {
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
        let bundle = NSBundle(identifier: "com.getflow.tests")!
        let path = bundle.pathForResource("text", ofType: "txt")!
        let stream = NSInputStream(fileAtPath: path)!
        builder.appendFormData("file",
          stream: stream,
          fileName: "text.txt",
          contentType: "plain/text")
      }

      fit("works") {
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
