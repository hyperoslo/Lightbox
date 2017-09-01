import UIKit

public protocol InfoLabelDelegate: class {

  func infoLabel(_ infoLabel: InfoLabel, didExpand expanded: Bool)
}

open class InfoLabel: UILabel {

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(labelDidTap(_:)))

    return gesture
  }()

  open var numberOfVisibleLines = 2

  var ellipsis: String {
    return "... \(LightboxConfig.InfoLabel.ellipsisText)"
  }

  open weak var delegate: InfoLabelDelegate?
  fileprivate var shortText = ""

  var fullText: String {
    didSet {
      shortText = truncatedText
      updateText(fullText)
      configureLayout()
    }
  }

  var expandable: Bool {
    return shortText != fullText
  }

  fileprivate(set) var expanded = false {
    didSet {
      delegate?.infoLabel(self, didExpand: expanded)
    }
  }

  fileprivate var truncatedText: String {
    var truncatedText = fullText

    guard numberOfLines(fullText) > numberOfVisibleLines else {
      return truncatedText
    }

    while numberOfLines(truncatedText) > numberOfVisibleLines * 2 {
        truncatedText = String(truncatedText.characters.prefix(truncatedText.characters.count / 2))
    }

    truncatedText += ellipsis

    let start = truncatedText.characters.index(truncatedText.endIndex, offsetBy: -(ellipsis.characters.count + 1))
    let end = truncatedText.characters.index(truncatedText.endIndex, offsetBy: -ellipsis.characters.count)
    var range = start..<end

    while numberOfLines(truncatedText) > numberOfVisibleLines {
      truncatedText.removeSubrange(range)
      range = truncatedText.index(range.lowerBound, offsetBy: -1)..<truncatedText.index(range.upperBound, offsetBy: -1)
    }

    return truncatedText
  }

  // MARK: - Initialization

  public init(text: String, expanded: Bool = false) {
    self.fullText = text
    super.init(frame: CGRect.zero)

    numberOfLines = 0
    updateText(text)
    self.expanded = expanded

    addGestureRecognizer(tapGestureRecognizer)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  func labelDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
    shortText = truncatedText
    expanded ? collapse() : expand()
  }

  func expand() {
    frame.size.height = heightForString(fullText)
    updateText(fullText)

    expanded = expandable
  }

  func collapse() {
    frame.size.height = heightForString(shortText)
    updateText(shortText)

    expanded = false
  }

  fileprivate func updateText(_ string: String) {
    let attributedString = NSMutableAttributedString(string: string,
      attributes: LightboxConfig.InfoLabel.textAttributes)

    if string.range(of: ellipsis) != nil {
      let range = (string as NSString).range(of: ellipsis)
      attributedString.addAttribute(NSForegroundColorAttributeName,
        value: LightboxConfig.InfoLabel.ellipsisColor, range: range)
    }

    attributedText = attributedString
  }

  // MARK: - Helper methods

  fileprivate func heightForString(_ string: String) -> CGFloat {
    return string.boundingRect(
      with: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [NSFontAttributeName: font],
      context: nil).height
  }

  fileprivate func numberOfLines(_ string: String) -> Int {
    let lineHeight = "A".size(attributes: [NSFontAttributeName: font]).height
    let totalHeight = heightForString(string)

    return Int(totalHeight / lineHeight)
  }
}

// MARK: - LayoutConfigurable

extension InfoLabel: LayoutConfigurable {

  public func configureLayout() {
    shortText = truncatedText
    expanded ? expand() : collapse()
  }
}
