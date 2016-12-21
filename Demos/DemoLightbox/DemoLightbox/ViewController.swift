import UIKit
import Lightbox

class ViewController: UIViewController {
  
  lazy var showButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.addTarget(self, action: #selector(showLightbox), for: .touchUpInside)
    button.setTitle("Show me the lightbox", for: UIControlState())
    button.setTitleColor(UIColor(red:0.47, green:0.6, blue:0.13, alpha:1), for: UIControlState())
    button.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 30)
    button.frame = UIScreen.main.bounds
    button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    
    return button
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    view.backgroundColor = UIColor.white
    view.addSubview(showButton)
  }
  
  // MARK: - Action methods
  
  func showLightbox() {
    let images = [
      LightboxImage(imageURL: URL(string: "https://cdn.arstechnica.net/2011/10/05/iphone4s_sample_apple-4e8c706-intro.jpg")!),
      LightboxImage(
        image: UIImage(named: "photo1")!,
        text: "Some very long lorem ipsum text. Some very long lorem ipsum text. Some very long lorem ipsum text. Some very long lorem ipsum text"
      ),
      LightboxImage(
        image: UIImage(named: "photo2")!,
        text: "",
        videoURL: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
      ),
      LightboxImage(
        image: UIImage(named: "photo3")!,
        text: "Some very long lorem ipsum text."
      )
    ]
    
    let controller = LightboxController(images: images)
    controller.dynamicBackground = true
    
    present(controller, animated: true, completion: nil)
  }
}

