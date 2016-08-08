import UIKit

class AssetManager {

  static func image(named: String) -> UIImage? {
    let bundle = NSBundle(forClass: AssetManager.self)
    return UIImage(named: "Lightbox.bundle/\(named)", inBundle: bundle, compatibleWithTraitCollection: nil)
  }
}
