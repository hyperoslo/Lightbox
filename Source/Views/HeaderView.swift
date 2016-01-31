import UIKit

protocol HeaderViewDelegate: class {
  func headerView(headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
  func headerView(headerView: HeaderView, didPressCloseButton closeButton: UIButton)
}

class HeaderView: UIView {

  lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.model.closeButton.text,
      attributes: self.model.closeButton.textAttributes)
    let button = UIButton(type: .System)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.model.closeButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.model.closeButton.enabled

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
    closeButton.frame = CGRect(
      x: bounds.width - model.closeButton.size.width - 17, y: 0,
      width: model.closeButton.size.width, height: model.closeButton.size.height)

    deleteButton.frame = CGRect(
      x: 17, y: 0,
      width: model.deleteButton.size.width, height: model.deleteButton.size.height)
  }
}
