import UIKit

public class LightboxViewCell: UICollectionViewCell {

  public static let reuseIdentifier: String = "LightboxViewCell"

  var constraintsAdded = false

  public lazy var lightboxView: LightboxView = { [unowned self] in
    let lightboxView = LightboxView(frame: self.bounds)
    lightboxView.setTranslatesAutoresizingMaskIntoConstraints(false)

    self.contentView.addSubview(lightboxView)

    return lightboxView
    }()

  public override func layoutSubviews() {
    super.layoutSubviews()
    animator = UIDynamicAnimator(referenceView: lightboxView)
    parentViewController.transitionManager.sourceViewCell = self
    setupConstraints()
    lightboxView.updateViewLayout()
  }

  var animator: UIDynamicAnimator!
  var attachmentBehavior: UIAttachmentBehavior!
  var gravityBehaviour: UIGravityBehavior!
  var snapBehavior: UISnapBehavior!
  var parentViewController: LightboxController!

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
