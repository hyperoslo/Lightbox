import UIKit

public class LightboxImage: UIScrollView {

  public lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
  }()

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
    addGestureRecognizer(panGestureRecognizer)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func configureFrame(frame: CGRect) {
    imageView.frame = frame
    imageView.frame.size.width = frame.width - 4
    imageView.frame.origin.x = 2

    self.frame = frame
    contentSize = imageView.frame.size
  }
}

extension LightboxImage: UIScrollViewDelegate {

  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
