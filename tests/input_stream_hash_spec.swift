import Foundation
import Nimble
import Quick
@testable import MultipartDataBuilder

class InputStreamHashSpec: QuickSpec {

  override func spec() {

    describe("InputStreamHash") {

      it("hashes a known file correctly") {
        let md5 = try! createMD5String(InputStream(data: loadFixture("walter", ofType: "png")))
        expect(md5).to(equal("2655cc22d6eea8707a91cdb41c424011"))
      }

      it("hashes nothing correctly") {
        let md5 = try! createMD5String(InputStream(data: Data()))
        expect(md5).to(equal("d41d8cd98f00b204e9800998ecf8427e"))
      }

    }

  }

}
