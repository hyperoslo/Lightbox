import UIKit

class FooterView: UIView {

  let model: LightboxModel

  lazy var infoLabel: InfoLabel = { [unowned self] in
    let label = InfoLabel(model: self.model,
      text: self.model.text)
    label.hidden = !self.model.infoLabel.enabled
    label.textColor = .whiteColor()

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

  // MARK: - Initializers

  init(model: LightboxModel) {
    self.model = model
    super.init(frame: CGRectZero)

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
}

// MARK: - LayoutConfigurable

extension FooterView: LayoutConfigurable {

  func configureLayout() {
    pageLabel.frame.origin = CGPoint(
      x: (frame.width - pageLabel.frame.width) / 2,
      y: frame.height - pageLabel.frame.height - 2)

    separatorView.frame = CGRect(x: 0, y: pageLabel.frame.minY - 2.5,
      width: frame.width, height: 0.5)

    infoLabel.frame = CGRect(x: 17, y: 0, width: frame.width - 17 * 2, height: 35)
    infoLabel.resetFrame()
    infoLabel.frame.origin.y = separatorView.frame.minY - infoLabel.frame.height - 20
  }
}
