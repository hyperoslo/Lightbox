import UIKit

protocol HeaderViewDelegate: class {
  func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton)
  func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton)
  func headerView(_ headerView: HeaderView, didPressDownloadButton downloadButton: UIButton)
}

public enum HeaderViewChildPosition {
  case start
  case center
  case end
}

open class HeaderView: UIView {
  open fileprivate(set) lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.CloseButton.text,
      attributes: LightboxConfig.CloseButton.textAttributes)

    let button = UIButton(type: .system)

    button.setAttributedTitle(title, for: UIControlState())

    if let size = LightboxConfig.CloseButton.size {
      button.frame.size = size
    } else {
      button.sizeToFit()
    }

    button.addTarget(self, action: #selector(closeButtonDidPress(_:)),
      for: .touchUpInside)

    if let image = LightboxConfig.CloseButton.image {
      button.setBackgroundImage(image, for: UIControlState())
    }

    button.isHidden = !LightboxConfig.CloseButton.enabled

    return button
  }()
  
  open fileprivate(set) lazy var downloadButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.DownloadButton.text,
      attributes: LightboxConfig.DownloadButton.textAttributes)
    
    let button = UIButton(type: .system)
    
    button.setAttributedTitle(title, for: UIControlState())
    
    if let size = LightboxConfig.DownloadButton.size {
      button.frame.size = size
    } else {
      button.sizeToFit()
    }
    
    button.addTarget(self, action: #selector(downloadButtonDidPress(_:)), for: .touchUpInside)
    
    if let image = LightboxConfig.DownloadButton.image {
      button.setBackgroundImage(image, for: UIControlState())
    }
    
    button.isHidden = !LightboxConfig.DownloadButton.enabled
    
    return button
    }()

  open fileprivate(set) lazy var activityIndicator: UIActivityIndicatorView = { [unowned self] in
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    if let size = LightboxConfig.DownloadButton.size {
      activityIndicator.frame.size = size
    } else {
      activityIndicator.sizeToFit()
    }
    
    activityIndicator.isHidden = true
    
    return activityIndicator
    }()
  
  open fileprivate(set) lazy var deleteButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: LightboxConfig.DeleteButton.text,
      attributes: LightboxConfig.DeleteButton.textAttributes)

    let button = UIButton(type: .system)

    button.setAttributedTitle(title, for: .normal)

    if let size = LightboxConfig.DeleteButton.size {
      button.frame.size = size
    } else {
      button.sizeToFit()
    }

    button.addTarget(self, action: #selector(deleteButtonDidPress(_:)),
      for: .touchUpInside)

    if let image = LightboxConfig.DeleteButton.image {
      button.setBackgroundImage(image, for: UIControlState())
    }

    button.isHidden = !LightboxConfig.DeleteButton.enabled

    return button
  }()

  let gradientColors = LightboxConfig.Header.gradientColors
  weak var delegate: HeaderViewDelegate?

  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)
    
    backgroundColor = UIColor.clear
    
    if LightboxConfig.Header.displayGradient {
      _ = addGradientLayer(gradientColors)
    }

    [closeButton, deleteButton, downloadButton, activityIndicator].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions
  @objc func deleteButtonDidPress(_ button: UIButton) {
    delegate?.headerView(self, didPressDeleteButton: button)
  }
  
  @objc func closeButtonDidPress(_ button: UIButton) {
    delegate?.headerView(self, didPressCloseButton: button)
  }
  
  @objc func downloadButtonDidPress(_ button: UIButton) {
    delegate?.headerView(self, didPressDownloadButton: button)
  }
  
  func showActivityIndicator() {
    activityIndicator.startAnimating()
    activityIndicator.isHidden = false
    downloadButton.isHidden = true
  }
  
  func hideActivityIndicator() {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
    downloadButton.isHidden = false
  }

}

// MARK: - LayoutConfigurable

extension HeaderView: LayoutConfigurable {

  @objc public func configureLayout() {
    let topPadding: CGFloat

    if #available(iOS 11, *) {
      topPadding = safeAreaInsets.top + LightboxConfig.Header.topPadding
    } else {
      topPadding = LightboxConfig.Header.topPadding
    }

    closeButton.frame.origin = CGPoint(
      x: getX(position: LightboxConfig.CloseButton.position, buttonWidth: closeButton.frame.width),
      y: topPadding
    )
    
    downloadButton.frame.origin = CGPoint(
      x: getX(position: LightboxConfig.DownloadButton.position, buttonWidth: downloadButton.frame.width),
      y: topPadding
    )

    activityIndicator.frame.origin = downloadButton.frame.origin
    
    deleteButton.frame.origin = CGPoint(
      x: getX(position: LightboxConfig.DeleteButton.position, buttonWidth: deleteButton.frame.width),
      y: topPadding
    )
  }
  
  fileprivate func getX(position: HeaderViewChildPosition, buttonWidth: CGFloat) -> CGFloat {
    switch position {
    case .start:
      return 17
    case .center:
      return (self.frame.width - buttonWidth) / 2
    case .end:
      return bounds.width - buttonWidth - 17
    }
  }
}
