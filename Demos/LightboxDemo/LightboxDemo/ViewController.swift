import UIKit
import Lightbox

class ViewController: UIViewController {

  lazy var lightboxView: LightboxView = { [unowned self] in
    let image = UIImage(named: "photo1")!
    let view = LightboxView(frame: self.view.frame, image: image)

    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(lightboxView)
  }
}

