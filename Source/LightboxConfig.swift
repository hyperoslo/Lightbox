import UIKit

class LightboxConfig {

  var config = Config()

  static let sharedInstance = LightboxConfig()
}

public struct Config {

  public var background = UIColor.blackColor()

  public struct PageIndicator {
    public var enabled = true
    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.lightGrayColor()
    ]
  }

  public struct CloseButton {
    public var enabled = true
    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.lightGrayColor()
    ]
    public var text = NSLocalizedString("Close", comment: "")
    public var borderColor = UIColor.whiteColor()
  }

  public struct Zoom {
    public var enabled = true
    public var minimumScale: CGFloat = 1.0
    public var maximumScale: CGFloat = 3.0
  }
}
