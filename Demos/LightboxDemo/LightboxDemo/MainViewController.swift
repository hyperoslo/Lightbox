import UIKit
import Lightbox

class MainViewController: UIViewController {

  lazy var galleryButton: UIButton = {
    let button = UIButton()
    button.setTitle("Show the gallery", forState: .Normal)
    button.tintColor = UIColor(red:0.98, green:0.18, blue:0.36, alpha:1)
    button.titleLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold ", size: 24)
    button.addTarget(self, action: "galleryButtonDidPress:", forControlEvents: .TouchUpInside)

    return button
    }()

  lazy var lightboxController: LightboxController = { [unowned self] in
    let controller = LightboxController(images: self.images)

    return controller
    }()

  let images = ["photo1", "photo2", "photo3"]

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(galleryButton)
  }

  // MARK: Action handlers

  func galleryButtonDidPress(button: UIButton) {
    presentViewController(lightboxController, animated: true, completion: nil)
  }
}
