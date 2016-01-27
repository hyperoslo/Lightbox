import UIKit

protocol PageViewDelegate: class {

  func pageVewDidZoom(pageView: PageView)
}

class PageView: UIScrollView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
    }()

  weak var pageViewDelegate: PageViewDelegate?
  var imageURL: NSURL?

  // MARK: - Initializers

  init(image: UIImage) {
    super.init(frame: CGRectZero)
    imageView.image = image
    configure()
    userInteractionEnabled = true
  }

  init(imageURL: NSURL) {
    super.init(frame: CGRectZero)

    self.imageURL = imageURL
    configure()

    LightboxConfig.config.loadImage(imageView: imageView, URL: imageURL) { error in
      guard error == nil else { return }
      self.userInteractionEnabled = true
      self.configureImageView()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configure() {
    addSubview(imageView)

    delegate = self
    multipleTouchEnabled = true
    minimumZoomScale = LightboxConfig.config.zoom.minimumScale
    maximumZoomScale = LightboxConfig.config.zoom.maximumScale
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false

    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
    doubleTapRecognizer.numberOfTapsRequired = 2
    doubleTapRecognizer.numberOfTouchesRequired = 1
    addGestureRecognizer(doubleTapRecognizer)
  }

  // MARK: - Recognizers

  func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
    let pointInView = recognizer.locationInView(imageView)
    let newZoomScale = zoomScale > minimumZoomScale
      ? minimumZoomScale
      : maximumZoomScale

    let width = bounds.size.width / newZoomScale
    let height = bounds.size.height / newZoomScale
    let x = pointInView.x - (width / 2.0)
    let y = pointInView.y - (height / 2.0)

    let rectToZoomTo = CGRectMake(x, y, width, height)

    zoomToRect(rectToZoomTo, animated: true)
  }

  // MARK: - Layout

  func configureLayout(frame: CGRect) {
    self.frame = frame
    contentSize = frame.size
    imageView.frame = frame
    zoomScale = LightboxConfig.config.zoom.minimumScale
  }

  func configureImageView() {
    guard let image = imageView.image else { return }

    let imageViewSize = imageView.frame.size
    let imageSize = image.size
    let realImageViewSize: CGSize

    if imageSize.width / imageSize.height > imageViewSize.width / imageViewSize.height {
      realImageViewSize = CGSize(
        width: imageViewSize.width,
        height: imageViewSize.width / imageSize.width * imageSize.height)
    } else {
      realImageViewSize = CGSize(
        width: imageViewSize.height / imageSize.height * imageSize.width,
        height: imageViewSize.height)
    }

    imageView.frame = CGRect(origin: CGPointZero, size: realImageViewSize)

    centerImageView()
  }

  func centerImageView() {
    let boundsSize = bounds.size
    var imageViewFrame = imageView.frame

    if imageViewFrame.size.width < boundsSize.width {
      imageViewFrame.origin.x = (boundsSize.width - imageViewFrame.size.width) / 2.0
    } else {
      imageViewFrame.origin.x = 0.0
    }

    if imageViewFrame.size.height < boundsSize.height {
      imageViewFrame.origin.y = (boundsSize.height - imageViewFrame.size.height) / 2.0
    } else {
      imageViewFrame.origin.y = 0.0
    }

    imageView.frame = imageViewFrame
  }
}

// MARK: - UIScrollViewDelegate

extension PageView: UIScrollViewDelegate {

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerImageView()
    pageViewDelegate?.pageVewDidZoom(self)
  }
}
