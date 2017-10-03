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
  
  @objc func showLightbox() {
    let images = [
      LightboxImage(imageURL: URL(string: "https://cdn.arstechnica.net/2011/10/05/iphone4s_sample_apple-4e8c706-intro.jpg")!),
      LightboxImage(
        image: UIImage(named: "photo1")!,
        text: "Some very long lorem ipsum text. Some very long lorem ipsum text. Some very long lorem ipsum text. Some very long lorem ipsum text"
      ),
      LightboxImage(
        image: UIImage(named: "photo2")!,
        text: "🌲 🌲 🌲 🌲 🌲 🌲 🌲 🌲 🌲 🌲 🌲    🏃 🌲 🏃‍♀️ 🌲 🌲 🌲 🌲  🌲 🌲 🌲 🌲\n\nSuspendisse massa massa, maximus et finibus ac, auctor volutpat diam.\n\nPellentesque consequat magna condimentum mauris bibendum, nec ornare nisl hendrerit. Phasellus nec ultrices sem. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\nSuspendisse sit amet facilisis ante, ac suscipit sem. Integer feugiat sit amet erat sit amet mattis. Donec tristique, nunc ut varius elementum, nisi elit viverra ipsum, vitae aliquam justo libero in arcu. Quisque tempor et justo at malesuada. Curabitur justo dolor, ornare convallis sollicitudin sed, consectetur eu turpis. \n\nNulla et dui condimentum, laoreet lacus eu, ultrices nisl. Vivamus in ante volutpat, gravida nunc scelerisque, sagittis tellus. Nullam justo purus, sagittis a tincidunt a, maximus nec sem.",
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

