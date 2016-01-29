import UIKit

protocol FooterViewDelegate: class {

  func footerView(footerView: FooterView, didExpand expanded: Bool)
}

class FooterView: UIView {

  lazy var infoLabel: InfoLabel = { [unowned self] in
    let label = InfoLabel(model: self.model, text: "")
    label.hidden = !self.model.infoLabel.enabled
    label.textColor = .whiteColor()
    label.userInteractionEnabled = true
    label.delegate = self

    return label
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.hidden = !self.model.pageIndicator.enabled
    label.numberOfLines = 1

    return label
    }()

  lazy var separatorView: UIView = { [unowned self] in
    let view = UILabel(frame: CGRectZero)
    view.hidden = !self.model.pageIndicator.enabled
    view.backgroundColor = self.model.pageIndicator.separatorColor

    return view
    }()

  let model: LightboxModel
  let gradientColors = [UIColor.hex("040404").alpha(0.1), UIColor.hex("040404")]
  weak var delegate: FooterViewDelegate?

  // MARK: - Initializers

  init(model: LightboxModel) {
    self.model = model
    super.init(frame: CGRectZero)

    backgroundColor = UIColor.clearColor()
    addGradientLayer(gradientColors)

    [pageLabel, infoLabel, separatorView].forEach { addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Helpers

  func expand(expand: Bool) {
    expand ? infoLabel.expand() : infoLabel.collapse()
  }

  func updatePage(page: Int, _ numberOfPages: Int) {
    let text = "\(page)/\(numberOfPages)"

    pageLabel.attributedText = NSAttributedString(string: text,
      attributes: model.pageIndicator.textAttributes)
    pageLabel.sizeToFit()
  }

  func updateText(text: String) {
    infoLabel.fullText = text
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

  func configureLayout() {
    infoLabel.frame = CGRect(x: 17, y: 0, width: frame.width - 17 * 2, height: 35)
    infoLabel.configureLayout()
  }
}

extension FooterView: InfoLabelDelegate {

  func infoLabel(infoLabel: InfoLabel, didExpand expanded: Bool) {
    resetFrames()
    expanded ? removeGradientLayer() : addGradientLayer(gradientColors)
    delegate?.footerView(self, didExpand: expanded)
  }
}
