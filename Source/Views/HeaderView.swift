import UIKit

protocol HeaderViewDelegate: class {
  func headerView(headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
  func headerView(headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

class HeaderView: UIView {

  lazy var closeButton: UIButton = { [unowned self] in

    var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
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
    let button = UIButton(type: .System)
    let title = NSAttributedString(
      string: self.model.deleteButton.text,
      attributes: self.model.deleteButton.textAttributes)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.model.deleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.model.deleteButton.enabled

    return button
    }()

  let model: LightboxModel
  weak var delegate: HeaderViewDelegate?

  // MARK: - Initializers

  init(model: LightboxModel) {
    self.model = model
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

    deleteButton.frame = CGRect(
      x: 17, y: 0,
      width: model.deleteButton.size.width, height: model.deleteButton.size.height)
  }
}
