import UIKit

public class LightboxViewCell: UICollectionViewCell {

  public static let reuseIdentifier: String = "LightboxViewCell"

  var constraintsAdded = false
  weak var parentViewController: LightboxController?

  public lazy var lightboxView: LightboxView = { [unowned self] in
    let lightboxView = LightboxView(frame: self.bounds)
    lightboxView.translatesAutoresizingMaskIntoConstraints = false

    self.contentView.addSubview(lightboxView)

    return lightboxView
    }()

  public override func layoutSubviews() {
    super.layoutSubviews()
    setupConstraints()
    lightboxView.updateViewLayout()
  }

  public func setupTransitionManager() {
    guard let controller = parentViewController else { return }
    controller.transitionManager.sourceViewCell = self
    controller.transitionManager.animator = UIDynamicAnimator(referenceView: lightboxView)
  }

  private func setupConstraints() {
    if !constraintsAdded {
      let layoutAttributes: [NSLayoutAttribute] = [.Leading, .Trailing, .Top, .Bottom]
      for layoutAttribute in layoutAttributes {
        addConstraint(NSLayoutConstraint(item: lightboxView, attribute: layoutAttribute,
          relatedBy: .Equal, toItem: contentView, attribute: layoutAttribute,
          multiplier: 1, constant: 0))
      }

      constraintsAdded = true
    }
  }
}
