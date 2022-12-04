import UIKit
import Lightbox
import SDWebImage

class ViewController: UIViewController {
  
  lazy var showButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.addTarget(self, action: #selector(showLightbox), for: .touchUpInside)
    button.setTitle("Show me the lightbox", for: UIControl.State())
    button.setTitleColor(UIColor(red:0.47, green:0.6, blue:0.13, alpha:1), for: UIControl.State())
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
    title = "Lightbox"
    LightboxConfig.preload = 2
    LightboxConfig.loadImage = { imageView, url, completion in
      imageView.sd_setImage(with: url) { image, _, _ , _ in
        completion?(image)
      }
    }
  }
  
  // MARK: - Action methods
  
    @objc func showLightbox() {
        let images = [
            LightboxImage(imageURL: URL(string: "https://media.giphy.com/media/Ku65904QQe4yez448B/giphy.gif")!),
            LightboxImage(imageURL: URL(string: "https://media.giphy.com/media/lQDLwWUMPaAHvh8pAG/giphy.gif")!),
            LightboxImage(imageURL: URL(string: "https://media.giphy.com/media/ontKwPWJxARsuKaKqJ/giphy.gif")!),
            LightboxImage(
                image: UIImage(named: "photo1")!,
                text: "Photography is the science, art, application and practice of creating durable images by recording light or other electromagnetic radiation, either electronically by means of an image sensor, or chemically by means of a light-sensitive material such as photographic film"
            ),
            
            LightboxImage(imageURL: URL(string: "https://via.placeholder.com/300.png/09f/fff")!),
            
            
            LightboxImage(
                image: UIImage(named: "photo2")!,
                text: "Emoji 😍 (/ɪˈmoʊdʒi/; singular emoji, plural emoji or emojis;[4] from the Japanese 絵文字えもじ, pronounced [emodʑi]) are ideograms and smileys used in electronic messages and web pages. Emoji are used much like emoticons and exist in various genres, including facial expressions, common objects, places and types of weather 🌅☔️💦, and animals 🐶🐱",
                videoURL: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
            ),
            LightboxImage(
                image: UIImage(named: "photo3")!,
                text: "A lightbox is a translucent surface illuminated from behind, used for situations where a shape laid upon the surface needs to be seen with high contrast."
            ),
            LightboxImage(imageURL: URL(string: "https://c.tenor.com/kccsHXtdDn0AAAAC/alcohol-wine.gif")!)
        ]
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        
        present(controller, animated: true, completion: nil)
    }
}

