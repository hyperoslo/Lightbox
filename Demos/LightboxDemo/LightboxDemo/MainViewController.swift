import UIKit

class MainViewController: UIViewController {

  lazy var galleryButton: UIButton = {
    let button = UIButton()
    button.setTitle("Show the gallery", forState: .Normal)
    button.tintColor = UIColor(red:0.98, green:0.18, blue:0.36, alpha:1)
    button.titleLabel!.font = UIFont(name: "AvenirNextCondensed-DemiBold ", size: 24)
    button.addTarget(self, action: "galleryButtonDidPress:", forControlEvents: .TouchUpInside)

    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(galleryButton)
  }

  // MARK: Action handlers

  func galleryButtonDidPress(button: UIButton) {
    
  }
}
