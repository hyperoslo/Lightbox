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

  public lazy var loadingIndicator: UIActivityIndicatorView = { [unowned self] in
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    loadingIndicator.startAnimating()
    loadingIndicator.alpha = 0
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

    return loadingIndicator
    }()

  public override func layoutSubviews() {
    super.layoutSubviews()

    if loadingIndicator.superview == nil { self.contentView.addSubview(loadingIndicator) }

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

      addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .CenterX,
        relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .CenterY,
        relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY,
        multiplier: 1, constant: 0))

      constraintsAdded = true
    }
  }
}
