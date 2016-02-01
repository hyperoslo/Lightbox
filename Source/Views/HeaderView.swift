import UIKit

protocol HeaderViewDelegate: class {
  func headerView(headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
  func headerView(headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

class HeaderView: UIView {

  var centerTextStyle: NSMutableParagraphStyle = {
    var style = NSMutableParagraphStyle()
    style.alignment = .Center
    return style
  }()

  lazy var closeButton: UIButton = { [unowned self] in
    var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSParagraphStyleAttributeName: self.centerTextStyle
    ]

    let title = NSAttributedString(
      string: NSLocalizedString("Close", comment: ""),
      attributes: textAttributes)

    let button = UIButton(type: .System)

    button.frame.size = CGSize(width: 60, height: 25)
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress:",
      forControlEvents: .TouchUpInside)

    return button
    }()

  lazy var deleteButton: UIButton = { [unowned self] in
    var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
      NSForegroundColorAttributeName: UIColor.hex("FA2F5B"),
      NSParagraphStyleAttributeName: self.centerTextStyle
    ]

    let title = NSAttributedString(
      string: NSLocalizedString("Delete", comment: ""),
      attributes: textAttributes)

    let button = UIButton(type: .System)

    button.frame.size = CGSize(width: 70, height: 25)
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    return button
    }()

  weak var delegate: HeaderViewDelegate?

  // MARK: - Initializers

  init() {
    super.init(frame: CGRectZero)

    backgroundColor = UIColor.clearColor()

    [closeButton, deleteButton].forEach { addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  func deleteButtonDidPress(button: UIButton) {
    delegate?.headerView(self, didPressDeleteButton: button)
  }

  func closeButtonDidPress(button: UIButton) {
    delegate?.headerView(self, didPressCloseButton: button)
  }
}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

  func configureLayout() {
    closeButton.frame.origin = CGPoint(
      x: bounds.width - closeButton.frame.width - 17, y: 0)

    deleteButton.frame.origin = CGPoint(x: 17, y: 0)
  }
}
