import UIKit

class InfoView: UILabel {

  let numberOfVisibleLines = 2

  var ellipsis: String {
    return LightboxConfig.config.ellipsisText
  }

  private var fullText: String?

  var truncatedText: String {
    guard var truncatedText = fullText else { return "" }

    guard numberOfLines(truncatedText) > numberOfVisibleLines else {
      return truncatedText
    }

    truncatedText += ellipsis

    var range = Range<String.Index>(
      start: truncatedText.endIndex.advancedBy(-(ellipsis.characters.count + 1)),
      end: truncatedText.endIndex.advancedBy(-ellipsis.characters.count)
    )

    while numberOfLines(truncatedText) > numberOfVisibleLines {
      truncatedText.removeRange(range)
      range.startIndex = range.startIndex.advancedBy(-1)
      range.endIndex = range.endIndex.advancedBy(-1)
    }

    return truncatedText
  }

  // MARK: - Actions

  func expand() {
    guard let fullText = fullText else { return }

    frame.size.height = heightForString(fullText)
    text = fullText
  }

  func collapse() {
    let string = truncatedText

    frame.size.height = heightForString(string)
    text = string
  }

  // MARK: - Helper methods

  private func heightForString(string: String) -> CGFloat {
    return string.boundingRectWithSize(
      CGSizeMake(bounds.size.width, CGFloat.max),
      options: [.UsesLineFragmentOrigin, .UsesFontLeading],
      attributes: [NSFontAttributeName : font],
      context: nil).height
  }

  private func numberOfLines(string: String) -> Int {
    let lineHeight = "A".sizeWithAttributes([NSFontAttributeName: font]).height
    let totalHeight = heightForString(string)

    return Int(totalHeight / lineHeight)
  }
}
