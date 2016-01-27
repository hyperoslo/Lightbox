import UIKit

class PageView: UIScrollView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
    }()

  var imageURL: NSURL?

  // MARK: - Initializers

  init(image: UIImage) {
    super.init(frame: CGRectZero)
    imageView.image = image
    configure()
  }

  init(imageURL: NSURL) {
    super.init(frame: CGRectZero)

    self.imageURL = imageURL
    configure()

    LightboxConfig.config.loadImage(imageView: imageView, URL: imageURL) { _ in }
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
    userInteractionEnabled = true
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

    let imgViewSize = imageView.frame.size
    let imageSize = imageView.image!.size

    zoomScale = LightboxConfig.config.zoom.minimumScale

    var realImgSize: CGSize
    if(imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height) {
      realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height);
    }
    else {
      realImgSize = CGSizeMake(imgViewSize.height / imageSize.height * imageSize.width, imgViewSize.height);
    }

    var fr = CGRectMake(0, 0, 0, 0)
    fr.size = realImgSize
    imageView.frame = fr
    centerImageView()
  }

  func centerImageView() {
    let boundsSize = bounds.size
    var contentsFrame = imageView.frame

    if contentsFrame.size.width < boundsSize.width {
      contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
    } else {
      contentsFrame.origin.x = 0.0
    }

    if contentsFrame.size.height < boundsSize.height {
      contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
    } else {
      contentsFrame.origin.y = 0.0
    }

    imageView.frame = contentsFrame
  }
}

// MARK: - UIScrollViewDelegate

extension PageView: UIScrollViewDelegate {

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerImageView()
  }
}
