import UIKit

protocol PageViewDelegate: class {

  func pageViewDidZoom(pageView: PageView)
  func remoteImageDidLoad(image: UIImage?)
  func pageView(pageView: PageView, didTouchPlayButton videoURL: NSURL)
}

class PageView: UIScrollView {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
    }()

  lazy var playButton: UIButton = {
    let button = UIButton(type: .Custom)
    button.frame.size = CGSize(width: 60, height: 60)
    button.setBackgroundImage(AssetManager.image("lightbox_play"), forState: .Normal)
    button.addTarget(self, action: #selector(playButtonTouched(_:)), forControlEvents: .TouchUpInside)

    button.layer.shadowOffset = CGSize(width: 1, height: 1)
    button.layer.shadowColor = UIColor.grayColor().CGColor
    button.layer.masksToBounds = false
    button.layer.shadowOpacity = 0.8

    return button
  }()

  var image: LightboxImage
  var contentFrame = CGRect.zero
  weak var pageViewDelegate: PageViewDelegate?

  // MARK: - Initializers

  init(image: LightboxImage) {
    self.image = image
    super.init(frame: CGRect.zero)

    self.image.addImageTo(imageView) { image in
      self.userInteractionEnabled = true
      self.configureImageView()
      self.pageViewDelegate?.remoteImageDidLoad(image)
    }

    configure()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configure() {
    addSubview(imageView)

    if image.videoURL != nil {
      addSubview(playButton)
    }

    delegate = self
    multipleTouchEnabled = true
    minimumZoomScale = LightboxConfig.Zoom.minimumScale
    maximumZoomScale = LightboxConfig.Zoom.maximumScale
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false

    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
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

    let width = contentFrame.size.width / newZoomScale
    let height = contentFrame.size.height / newZoomScale
    let x = pointInView.x - (width / 2.0)
    let y = pointInView.y - (height / 2.0)

    let rectToZoomTo = CGRect(x: x, y: y, width: width, height: height)

    zoomToRect(rectToZoomTo, animated: true)
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    playButton.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
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

    imageView.frame = CGRect(origin: CGPoint.zero, size: realImageViewSize)

    centerImageView()
  }

  func centerImageView() {
    let boundsSize = contentFrame.size
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

  // MARK: - Action

  func playButtonTouched(button: UIButton) {
    guard let videoURL = image.videoURL else { return }

    pageViewDelegate?.pageView(self, didTouchPlayButton: videoURL)
  }
}

// MARK: - LayoutConfigurable

extension PageView: LayoutConfigurable {

  func configureLayout() {
    contentFrame = frame
    contentSize = frame.size
    imageView.frame = frame
    zoomScale = minimumZoomScale

    configureImageView()
  }
}

// MARK: - UIScrollViewDelegate

extension PageView: UIScrollViewDelegate {

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(scrollView: UIScrollView) {
    centerImageView()
    pageViewDelegate?.pageViewDidZoom(self)
  }
}
