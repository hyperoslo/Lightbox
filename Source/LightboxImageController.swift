import UIKit

public class LightboxImage: UIScrollView {

  public lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
  }()

  public lazy var transitionManager: LightboxTransition = LightboxTransition()

  // MARK: - Initializers

  public init(image: UIImage) {
    super.init(frame: CGRectZero)

    addSubview(imageView)

    imageView.image = image

    delegate = self
    multipleTouchEnabled = true
    minimumZoomScale = 1
    maximumZoomScale = 2.5
    userInteractionEnabled = true
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    transitionManager.scrollView = self
    addGestureRecognizer(panGestureRecognizer)

    setupFrames()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Main methods

  public func setupFrames() {
    imageView.frame = UIScreen.mainScreen().bounds
    imageView.frame.size.width = UIScreen.mainScreen().bounds.width - 4
    imageView.frame.origin.x = 2

    frame = UIScreen.mainScreen().bounds
    contentSize = imageView.frame.size
  }
}

extension LightboxImage: UIScrollViewDelegate {

  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
