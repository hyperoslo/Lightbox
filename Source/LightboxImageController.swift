import UIKit

public class LightboxImageController: UIViewController {

  public lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFit
    imageView.clipsToBounds = true

    return imageView
  }()

  // MARK: - Initializers

  public init(image: UIImage) {
    super.init(nibName: nil, bundle: nil)

    view.addSubview(imageView)

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
    imageView.frame.size.width = UIScreen.mainScreen().bounds.width - 30
  }
}
