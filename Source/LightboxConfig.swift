import UIKit
import Hue

public class LightboxConfig {

  public typealias LoadImageCompletion = (error: NSError?, image: UIImage?) -> Void

  public static var hideStatusBar = true

  public static var loadImage: (imageView: UIImageView, URL: NSURL, completion: LoadImageCompletion?) -> Void = {
    imageView, URL, completion in
    let imageRequest: NSURLRequest = NSURLRequest(URL: URL)

    NSURLConnection.sendAsynchronousRequest(imageRequest,
      queue: NSOperationQueue.mainQueue(),
      completionHandler: { response, data, error in
        if let data = data, image = UIImage(data: data) {
          imageView.image = image
        }

        completion?(error: error, image: imageView.image)
    })
  }

  public struct PageIndicator {
    public static var enabled = true
    public static var separatorColor = UIColor.hex("3D4757")

    public static var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.hex("899AB8"),
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
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
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
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
      NSForegroundColorAttributeName: UIColor.hex("FA2F5B"),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
  }

  public struct InfoLabel {
    public static var enabled = true
    public static var textColor = UIColor.whiteColor()
    public static var ellipsisText = NSLocalizedString("Show more", comment: "")
    public static var ellipsisColor = UIColor.hex("899AB9")

    public static var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.hex("DBDBDB")
    ]
  }

  public struct Zoom {
    public static var minimumScale: CGFloat = 1.0
    public static var maximumScale: CGFloat = 3.0
  }
}
