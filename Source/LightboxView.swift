import UIKit

public class LightboxView: UIView {

  public var image: UIImage? {
    didSet {
      imageView.image = image
      if constraintsAdded {
        updateImageConstraints()
        updateZoom()
      }
    }
  }

  public var minimumZoomScale: CGFloat = 1
  public var maximumZoomScale: CGFloat = 3
  var lastZoomScale: CGFloat = -1

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: CGRectZero)
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    return imageView
  }()

  lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView(frame: CGRectZero)
    scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
    scrollView.multipleTouchEnabled = true
    scrollView.minimumZoomScale = self.minimumZoomScale
    scrollView.maximumZoomScale = self.maximumZoomScale
    scrollView.delegate = self
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false

    return scrollView
  }()

  var imageConstraintLeading: NSLayoutConstraint!
  var imageConstraintTrailing: NSLayoutConstraint!
  var imageConstraintTop: NSLayoutConstraint!
  var imageConstraintBottom: NSLayoutConstraint!

  var constraintsAdded = false

  // MARK: - Initialization

  public init(frame: CGRect, image: UIImage? = nil) {
    super.init(frame: frame)

    imageView.image = image
    backgroundColor = .blackColor()

    scrollView.addSubview(self.imageView)
    addSubview(scrollView)
  }

  public required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func didMoveToSuperview() {
    setUpConstraints()
  }

  // MARK: - Autolayout

  public override func layoutSubviews() {
    super.layoutSubviews()
    if constraintsAdded {
      updateImageConstraints()
      updateZoom()
    }
  }

  public func setUpConstraints() {
    if !constraintsAdded {
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

      scrollView.contentSize = CGSize(width: frame.size.width, height: frame.size.height)

      constraintsAdded = true
    }
  }

  public func updateImageConstraints() {
    if let image = imageView.image {
      let viewWidth = bounds.size.width
      let viewHeight = bounds.size.height

      let imageWidth = image.size.width
      let imageHeight = image.size.height

      // Center image
      var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
      if hPadding < 0 {
        hPadding = 0
      }

      var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
      if vPadding < 0 {
        vPadding = 0
      }

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
      var minimumZoom = min(
        bounds.size.width / image.size.width,
        bounds.size.height / image.size.height)

      if minimumZoom > 1 {
        minimumZoom = 1
      }

      scrollView.minimumZoomScale = minimumZoom

      if minimumZoom == lastZoomScale {
        minimumZoom += 0.000001
      }

      scrollView.zoomScale = minimumZoom
      lastZoomScale = minimumZoom
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
