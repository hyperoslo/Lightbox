import UIKit

class ViewController: UIViewController {

  lazy var showButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.addTarget(self, action: "showLightbox", forControlEvents: .TouchUpInside)
    button.setTitle("Show me the lightbox", forState: .Normal)
    button.setTitleColor(UIColor(red:0.47, green:0.6, blue:0.13, alpha:1), forState: .Normal)
    button.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 30)
    button.frame = UIScreen.mainScreen().bounds

    return button
    }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(showButton)
  }

  // MARK: - Action methods

  func showLightbox() {
    // TODO: - Lightbox
  }
}

