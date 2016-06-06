import UIKit

public protocol InfoLabelDelegate: class {

  func infoLabel(infoLabel: InfoLabel, didExpand expanded: Bool)
}

public class InfoLabel: UILabel {

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(labelDidTap(_:)))

    return gesture
  }()

  public var numberOfVisibleLines = 2

  var ellipsis: String {
    return "... \(LightboxConfig.InfoLabel.ellipsisText)"
  }

  public weak var delegate: InfoLabelDelegate?
  private var shortText = ""

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

  private(set) var expanded = false {
    didSet {
      delegate?.infoLabel(self, didExpand: expanded)
    }
  }

  private var truncatedText: String {
    var truncatedText = fullText

    guard numberOfLines(fullText) > numberOfVisibleLines else {
      return truncatedText
    }

    truncatedText += ellipsis

    let start = truncatedText.endIndex.advancedBy(-(ellipsis.characters.count + 1))
    let end = truncatedText.endIndex.advancedBy(-ellipsis.characters.count)
    var range = start..<end

    while numberOfLines(truncatedText) > numberOfVisibleLines {
      truncatedText.removeRange(range)
      range.startIndex = range.startIndex.advancedBy(-1)
      range.endIndex = range.endIndex.advancedBy(-1)
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

  func labelDidTap(tapGestureRecognizer: UITapGestureRecognizer) {
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

  private func updateText(string: String) {
    let attributedString = NSMutableAttributedString(string: string,
      attributes: LightboxConfig.InfoLabel.textAttributes)

    if string.rangeOfString(ellipsis) != nil {
      let range = (string as NSString).rangeOfString(ellipsis)
      attributedString.addAttribute(NSForegroundColorAttributeName,
        value: LightboxConfig.InfoLabel.ellipsisColor, range: range)
    }

    attributedText = attributedString
  }

  // MARK: - Helper methods

  private func heightForString(string: String) -> CGFloat {
    return string.boundingRectWithSize(
      CGSize(width: bounds.size.width, height: CGFloat.max),
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

// MARK: - LayoutConfigurable

extension InfoLabel: LayoutConfigurable {

  public func configureLayout() {
    shortText = truncatedText
    expanded ? expand() : collapse()
  }
}
