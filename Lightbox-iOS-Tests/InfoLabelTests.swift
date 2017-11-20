import XCTest
@testable import Lightbox

class InfoLabelTests: XCTestCase {
  func testTruncating() {
    let label = InfoLabel(text: "", expanded: false)
    label.frame.size = CGSize(width: 10, height: 10)

    // Run many iterations with increasing text length
    Array(0..<1000).forEach {
      let text = Array(repeating: "A", count: $0).joined(separator: "")
      label.fullText = text
      _ = label.truncatedText
    }
  }
}
