import UIKit

protocol HeaderViewDelegate: class {
  func headerView(headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
  func headerView(headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

public class HeaderView: UIView {

  var centerTextStyle: NSMutableParagraphStyle = {
    var style = NSMutableParagraphStyle()
    style.alignment = .Center
    return style
  }()

  public private(set) lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.CloseButton.text,
      attributes: LightboxConfig.CloseButton.textAttributes)

    let button = UIButton(type: .System)

    button.frame.size = LightboxConfig.CloseButton.size
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: #selector(closeButtonDidPress(_:)),
      forControlEvents: .TouchUpInside)

    if let image = LightboxConfig.CloseButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !LightboxConfig.CloseButton.enabled

    return button
    }()

  public private(set) lazy var deleteButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.DeleteButton.text,
      attributes: LightboxConfig.DeleteButton.textAttributes)

    let button = UIButton(type: .System)

    button.frame.size = LightboxConfig.DeleteButton.size
    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
      forControlEvents: .TouchUpInside)

    if let image = LightboxConfig.DeleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !LightboxConfig.DeleteButton.enabled

    return button
    }()

  weak var delegate: HeaderViewDelegate?

  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor.clearColor()

    [closeButton, deleteButton].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
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

  public func configureLayout() {
    closeButton.frame.origin = CGPoint(
      x: bounds.width - closeButton.frame.width - 17, y: 0)

    deleteButton.frame.origin = CGPoint(x: 17, y: 0)
  }
}
