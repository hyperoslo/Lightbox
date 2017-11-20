import XCTest
@testable import Lightbox

class InfoLabelTests: XCTestCase {
  func testTruncating() {
    let label = InfoLabel(text: "", expanded: false)
    label.frame.size = CGSize(width: 10, height: 10)

    let text = Array(repeating: "A", count: 4).joined(separator: "")
    label.fullText = text
    _ = label.truncatedText
  }
}
