import UIKit

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.frame = UIScreen.mainScreen().bounds

    return scrollView
    }()

  public lazy var closeButton: UIButton = {
    let button = UIButton()
    return button
    }()

  // MARK: - Initializers

  public init(images: [UIImage]) {
    super.init(nibName: nil, bundle: nil)

    scrollView.frame.size.width = UIScreen.mainScreen().bounds.width * CGFloat(images.count)

    setupControllers()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Main methods

  public func setupControllers(images: [UIImage]) {

    for (element, index) in images.enumerate() {
      let controller = LightboxImageController()
      controller.view.frame.origin.x = UIScreen.mainScreen().bounds.width * CGFloat(index)
      
      scrollView.addSubview(controller.view)
    }
  }
}
