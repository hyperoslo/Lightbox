import UIKit

class LightboxConfig {

  var config = Config()

  static let sharedInstance = LightboxConfig()
}

public struct Config {

  public var backgroundColor = UIColor.blackColor()
  public var pageIndicator = PageIndicator()
  public var closeButton = CloseButton()
  public var zoom = Zoom()
  
  public var loadImage: (imageView: UIImageView, URL: NSURL) -> Void = {
    imageView, URL in
    let imageRequest: NSURLRequest = NSURLRequest(URL: URL)
    
    NSURLConnection.sendAsynchronousRequest(imageRequest,
      queue: NSOperationQueue.mainQueue(),
      completionHandler: { response, data, error in
        if let data = data {
          imageView.image = UIImage(data: data)
        }
    })
  }

  public struct PageIndicator {
    public var enabled = true
    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(18),
      NSForegroundColorAttributeName: UIColor.lightGrayColor(),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
  }

  public struct CloseButton {
    public var enabled = true
    public var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
    public var size = CGSize(width: 60, height: 25)
    public var text = NSLocalizedString("Close", comment: "")
    public var borderColor = UIColor.whiteColor()
  }

  public struct Zoom {
    public var minimumScale: CGFloat = 1.0
    public var maximumScale: CGFloat = 3.0
  }
}
