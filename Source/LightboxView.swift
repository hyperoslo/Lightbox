import UIKit

public class LightboxView: UIView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: CGRectZero)
    return imageView
  }()

  lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView(frame: CGRectZero)
    scrollView.delegate = self
    scrollView.addSubview(self.imageView)
    return scrollView
  }()

  var imageConstraintLeading: NSLayoutConstraint!
  var imageConstraintTrailing: NSLayoutConstraint!
  var imageConstraintTop: NSLayoutConstraint!
  var imageConstraintBottom: NSLayoutConstraint!

  var lastZoomScale: CGFloat = -1

  // MARK: - Initialization

  public init(frame: CGRect, image: UIImage) {
    super.init(frame: frame)

    imageView.image = image
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func didMoveToSuperview() {
    setUpConstraints()
  }

  // MARK: - Autolayout

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

  public func updateImageConstraints() {
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

  // MARK: - Zoom

  public func updateZoom() {
    if let image = imageView.image {
      var minZoom = min(
        bounds.size.width / image.size.width,
        bounds.size.height / image.size.height)

      if minZoom > 1 {
        minZoom = 1
      }

      scrollView.minimumZoomScale = minZoom

      if minZoom == lastZoomScale {
        minZoom += 0.000001
      }

      scrollView.zoomScale = minZoom
      lastZoomScale = minZoom
    }
  }
}

// MARK: - UIScrollViewDelegate

extension LightboxView: UIScrollViewDelegate {

  public func scrollViewDidZoom(scrollView: UIScrollView) {
    updateImageConstraints()
  }

  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
