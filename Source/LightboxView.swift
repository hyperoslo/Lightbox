import UIKit

class LightboxView: UIView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: CGRectZero)
    return imageView
  }()

  var scrollView: UIScrollView = {
    let scrollView = UIScrollView(frame: CGRectZero)
    return scrollView
  }()

  var imageConstraintLeading: NSLayoutConstraint!
  var imageConstraintTrailing: NSLayoutConstraint!
  var imageConstraintTop: NSLayoutConstraint!
  var imageConstraintBottom: NSLayoutConstraint!

  var lastZoomScale: CGFloat = -1

  init(frame: CGRect, image: UIImage) {
    super.init(frame: frame)
    imageView.image = image
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    setUpConstraints()
  }

  func setUpConstraints() {
    addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Leading,
      relatedBy: .Equal, toItem: self, attribute: .Leading,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Trailing,
      relatedBy: .Equal, toItem: self, attribute: .Trailing,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Top,
      relatedBy: .Equal, toItem: self, attribute: .Top,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: scrollView, attribute: .Bottom,
      relatedBy: .Equal, toItem: self, attribute: .Bottom,
      multiplier: 1, constant: 0))

    imageConstraintLeading = NSLayoutConstraint(item: imageView, attribute: .Leading,
      relatedBy: .Equal, toItem: scrollView, attribute: .Leading,
      multiplier: 1, constant: 0)

    imageConstraintTrailing = NSLayoutConstraint(item: imageView, attribute: .Trailing,
      relatedBy: .Equal, toItem: scrollView, attribute: .Trailing,
      multiplier: 1, constant: 0)

    imageConstraintTop = NSLayoutConstraint(item: imageView, attribute: .Top,
      relatedBy: .Equal, toItem: scrollView, attribute: .Top,
      multiplier: 1, constant: 0)

    imageConstraintBottom = NSLayoutConstraint(item: imageView, attribute: .Bottom,
      relatedBy: .Equal, toItem: scrollView, attribute: .Bottom,
      multiplier: 1, constant: 0)

    addConstraints([imageConstraintLeading, imageConstraintTrailing,
      imageConstraintTop, imageConstraintBottom])

    layoutIfNeeded()
  }

  func updateImageConstraints() {
    if let image = imageView.image {
      let imageWidth = image.size.width
      let imageHeight = image.size.height

      let viewWidth = bounds.size.width
      let viewHeight = bounds.size.height

      // Center image if it is smaller than screen
      var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
      if hPadding < 0 { hPadding = 0 }

      var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
      if vPadding < 0 { vPadding = 0 }

      imageConstraintLeading.constant = hPadding
      imageConstraintTrailing.constant = hPadding

      imageConstraintTop.constant = vPadding
      imageConstraintBottom.constant = vPadding

      layoutIfNeeded()
    }
  }
}
