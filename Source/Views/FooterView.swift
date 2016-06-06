import UIKit

public protocol FooterViewDelegate: class {

  func footerView(footerView: FooterView, didExpand expanded: Bool)
}

public class FooterView: UIView {

  public private(set) lazy var infoLabel: InfoLabel = { [unowned self] in
    let label = InfoLabel(text: "")
    label.hidden = !LightboxConfig.InfoLabel.enabled

    label.textColor = LightboxConfig.InfoLabel.textColor
    label.userInteractionEnabled = true
    label.delegate = self

    return label
    }()

  public private(set) lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRect.zero)
    label.hidden = !LightboxConfig.PageIndicator.enabled
    label.numberOfLines = 1

    return label
    }()

  public private(set) lazy var separatorView: UIView = { [unowned self] in
    let view = UILabel(frame: CGRect.zero)
    view.hidden = !LightboxConfig.PageIndicator.enabled
    view.backgroundColor = LightboxConfig.PageIndicator.separatorColor

    return view
    }()

  let gradientColors = [UIColor.hex("040404").alpha(0.1), UIColor.hex("040404")]
  public weak var delegate: FooterViewDelegate?

  // MARK: - Initializers

  public init() {
    super.init(frame: CGRect.zero)

    backgroundColor = UIColor.clearColor()
    addGradientLayer(gradientColors)

    [pageLabel, infoLabel, separatorView].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Helpers

  func expand(expand: Bool) {
    expand ? infoLabel.expand() : infoLabel.collapse()
  }

  func updatePage(page: Int, _ numberOfPages: Int) {
    let text = "\(page)/\(numberOfPages)"

    pageLabel.attributedText = NSAttributedString(string: text,
      attributes: LightboxConfig.PageIndicator.textAttributes)
    pageLabel.sizeToFit()
  }

  func updateText(text: String) {
    infoLabel.fullText = text

    if text.isEmpty {
      removeGradientLayer()
    } else if !infoLabel.expanded {
      addGradientLayer(gradientColors)
    }
  }

  // MARK: - Layout

  private func resetFrames() {
    frame.size.height = infoLabel.frame.height + 40 + 0.5

    pageLabel.frame.origin = CGPoint(
      x: (frame.width - pageLabel.frame.width) / 2,
      y: frame.height - pageLabel.frame.height - 2)

    separatorView.frame = CGRect(x: 0, y: pageLabel.frame.minY - 2.5,
      width: frame.width, height: 0.5)

    infoLabel.frame.origin.y = separatorView.frame.minY - infoLabel.frame.height - 15

    resizeGradientLayer()
  }
}

// MARK: - LayoutConfigurable

extension FooterView: LayoutConfigurable {

  public func configureLayout() {
    infoLabel.frame = CGRect(x: 17, y: 0, width: frame.width - 17 * 2, height: 35)
    infoLabel.configureLayout()
  }
}

extension FooterView: InfoLabelDelegate {

  public func infoLabel(infoLabel: InfoLabel, didExpand expanded: Bool) {
    resetFrames()
    expanded ? removeGradientLayer() : addGradientLayer(gradientColors)
    delegate?.footerView(self, didExpand: expanded)
  }
}
