import UIKit

public class LightboxImageController: UIViewController {

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.delegate = self
    scrollView.multipleTouchEnabled = true
    scrollView.minimumZoomScale = 0.5
    scrollView.maximumZoomScale = 10
    scrollView.userInteractionEnabled = true

    return scrollView
    }()

  public lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true
    imageView.userInteractionEnabled = true

    return imageView
  }()

  // MARK: - Initializers

  public init(image: UIImage) {
    super.init(nibName: nil, bundle: nil)

    view.addSubview(scrollView)
    scrollView.addSubview(imageView)

    imageView.image = image

    setupFrames()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Main methods

  public func setupFrames() {
    imageView.frame = UIScreen.mainScreen().bounds
    imageView.frame.size.width = UIScreen.mainScreen().bounds.width - 4
    imageView.frame.origin.x = 2

    scrollView.frame = UIScreen.mainScreen().bounds
    scrollView.contentSize = imageView.frame.size
  }
}

extension LightboxImageController: UIScrollViewDelegate {

  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
