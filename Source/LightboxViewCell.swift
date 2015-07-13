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

    setupConstraints()
    lightboxView.updateViewLayout()
  }

  private func setupConstraints() {
    if !constraintsAdded {
      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Leading,
        relatedBy: .Equal, toItem: contentView, attribute: .Leading,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Trailing,
        relatedBy: .Equal, toItem: contentView, attribute: .Trailing,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Top,
        relatedBy: .Equal, toItem: contentView, attribute: .Top,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Bottom,
        relatedBy: .Equal, toItem: contentView, attribute: .Bottom,
        multiplier: 1, constant: 0))

      constraintsAdded = true
    }
  }
}
