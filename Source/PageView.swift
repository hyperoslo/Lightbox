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

    LightboxConfig.config.loadImage(
      imageView: imageView, URL: imageURL) { error in
        if error == nil {}
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure() {
    addSubview(imageView)

    delegate = self
    multipleTouchEnabled = true
    minimumZoomScale = LightboxConfig.config.zoom.minimumScale
    maximumZoomScale = LightboxConfig.config.zoom.maximumScale
    userInteractionEnabled = true
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    addGestureRecognizer(panGestureRecognizer)
  }

  func configureFrame(frame: CGRect) {
    imageView.frame = frame
    imageView.frame.size.width = frame.width
    imageView.frame.origin.x = 0

    self.frame = frame
    contentSize = imageView.frame.size
  }
}

// MARK: - UIScrollViewDelegate

extension PageView: UIScrollViewDelegate {

  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
