import UIKit

protocol InfoLabelDelegate: class {

  func infoLabel(infoLabel: InfoLabel, didExpand expanded: Bool)
}

class InfoLabel: UILabel {

  lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "labelDidTap:")

    return gesture
  }()

  let model: LightboxModel
  let numberOfVisibleLines = 2
  var fullText: String
  weak var delegate: InfoLabelDelegate?

  var ellipsis: String {
    return "... \(model.infoLabel.ellipsisText)"
  }

  var expanded = false {
    didSet {
      resetFrame()
    }
  }

  var truncatedText: String {
    var truncatedText = fullText

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

  // MARK: - Initialization

  init(model: LightboxModel, text: String, expanded: Bool = false) {
    self.model = model
    self.fullText = text
    super.init(frame: CGRectZero)

    numberOfLines = 0
    updateText(text)
    self.expanded = expanded

    addGestureRecognizer(tapGestureRecognizer)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func resetFrame() {
    expanded ? expand() : collapse()
  }

  // MARK: - Actions

  func labelDidTap(tapGestureRecognizer: UITapGestureRecognizer) {
    expanded = !expanded
    delegate?.infoLabel(self, didExpand: expanded)
  }

  private func expand() {
    frame.size.height = heightForString(fullText)
    updateText(fullText)
  }

  private func collapse() {
    let string = truncatedText

    frame.size.height = heightForString(string)
    updateText(string)
  }

  private func updateText(string: String) {
    let attributedString = NSMutableAttributedString(string: string,
      attributes: model.infoLabel.textAttributes)

    if string.rangeOfString(ellipsis) != nil {
      let range = (string as NSString).rangeOfString(ellipsis)
      attributedString.addAttribute(NSForegroundColorAttributeName,
        value: model.infoLabel.elipsisColor, range: range)
    }

    attributedText = attributedString
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
