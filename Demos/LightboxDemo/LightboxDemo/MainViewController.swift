import UIKit
import Lightbox

class MainViewController: UIViewController {

  lazy var galleryButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle("Show the gallery", forState: .Normal)
    button.setTitleColor(UIColor(red:0.98, green:0.18, blue:0.36, alpha:1), forState: .Normal)
    button.titleLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 24)
    button.addTarget(self, action: "galleryButtonDidPress:", forControlEvents: .TouchUpInside)
    button.frame = CGRectMake(0, 0,
      UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)

    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(galleryButton)
  }

  // MARK: Action handlers

  func galleryButtonDidPress(button: UIButton) {
    let controller = LightboxController(images: ["photo1", "photo2", "photo3"])
    controller.dismissalDelegate = self
    presentViewController(controller, animated: true, completion: nil)
  }
}

// MARK: Lightbox delegate methods

extension MainViewController : LightboxControllerDismissalDelegate {

  func lightboxControllerDidDismiss(controller: LightboxController) {
    controller.dismissViewControllerAnimated(true, completion: nil)
  }
}
