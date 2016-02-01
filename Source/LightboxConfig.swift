import UIKit
import Hue

public class LightboxConfig {

  public typealias LoadImageCompletion = (error: NSError?) -> Void

  public var hideStatusBar = true

  public static var loadImage: (imageView: UIImageView, URL: NSURL, completion: LoadImageCompletion?) -> Void = {
    imageView, URL, completion in
    let imageRequest: NSURLRequest = NSURLRequest(URL: URL)

    NSURLConnection.sendAsynchronousRequest(imageRequest,
      queue: NSOperationQueue.mainQueue(),
      completionHandler: { response, data, error in
        if let data = data, image = UIImage(data: data) {
          imageView.image = image
        }

        completion?(error: error)
    })
  }

  public struct PageIndicator {
    public static var enabled = true

    public static var textAttributes = [
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
    public static var enabled = true
    public static var size = CGSize(width: 60, height: 25)
    public static var text = NSLocalizedString("Close", comment: "")
    public static var image: UIImage?

    public static var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
  }

  public struct DeleteButton {
    public static var enabled = false
    public static var size = CGSize(width: 70, height: 25)
    public static var text = NSLocalizedString("Delete", comment: "")
    public static var image: UIImage?

    public static var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor(red:0.99, green:0.26, blue:0.18, alpha:1),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
  }

  public struct Zoom {
    public static var minimumScale: CGFloat = 1.0
    public static var maximumScale: CGFloat = 3.0
  }
}
