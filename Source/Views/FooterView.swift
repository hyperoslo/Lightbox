import UIKit

protocol FooterViewDelegate: class {

  func footerView(footerView: FooterView, didExpand expanded: Bool)
}

class FooterView: UIView {

  lazy var infoLabel: InfoLabel = { [unowned self] in
    let label = InfoLabel(model: self.model,
      text: self.model.text)
    label.hidden = !self.model.infoLabel.enabled
    label.textColor = .whiteColor()
    label.userInteractionEnabled = true

    return label
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.alpha = self.model.pageIndicator.enabled ? 1.0 : 0.0
    label.numberOfLines = 1

    return label
    }()

  lazy var separatorView: UIView = { [unowned self] in
    let view = UILabel(frame: CGRectZero)
    view.alpha = self.model.pageIndicator.enabled ? 1.0 : 0.0
    view.backgroundColor = self.model.pageIndicator.separatorColor

    return view
    }()

  let model: LightboxModel
  weak var delegate: FooterViewDelegate?

  var expanded = false {
    didSet {
      resetSubviewFrames()
    }
  }

  // MARK: - Initializers

  init(model: LightboxModel) {
    self.model = model
    super.init(frame: CGRectZero)

    let colors = [UIColor.hex("040404").alpha(0.87), UIColor.hex("040404")]
    setupGradient(colors)

    [pageLabel, infoLabel, separatorView].forEach { addSubview($0) }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Helpers

  func updatePage(page: Int, _ numberOfPages: Int) {
    let text = "\(page)/\(numberOfPages)"

    pageLabel.attributedText = NSAttributedString(string: text,
      attributes: model.pageIndicator.textAttributes)
    pageLabel.sizeToFit()
  }

  // MARK: - Layout

  func resetSubviewFrames() {
    frame.size.height = infoLabel.frame.height + 40 + 0.5

    pageLabel.frame.origin = CGPoint(
      x: (frame.width - pageLabel.frame.width) / 2,
      y: frame.height - pageLabel.frame.height - 2)

    separatorView.frame = CGRect(x: 0, y: pageLabel.frame.minY - 2.5,
      width: frame.width, height: 0.5)

    infoLabel.frame.origin.y = separatorView.frame.minY - infoLabel.frame.height - 20
  }
}

// MARK: - LayoutConfigurable

extension FooterView: LayoutConfigurable {

  func configureLayout() {
    infoLabel.frame = CGRect(x: 17, y: 0, width: frame.width - 17 * 2, height: 35)
    infoLabel.expanded = expanded

    resetSubviewFrames()
  }
}

extension FooterView: InfoLabelDelegate {

  func infoLabel(infoLabel: InfoLabel, didExpand expanded: Bool) {
    self.expanded = expanded
  }
}
