import UIKit

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
    }()

  public lazy var closeButton: UIButton = {
    let button = UIButton()
    return button
    }()

  // MARK: - Initializers

  public init(images: [UIImage]) {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

  }
}
