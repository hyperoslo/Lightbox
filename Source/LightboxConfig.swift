import UIKit
import Hue

public class LightboxModel {

  public typealias LoadImageCompletion = (error: NSError?) -> Void

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

  public var pageIndicator = PageIndicator()
  public var closeButton = CloseButton()
  public var deleteButton = DeleteButton()
  public var infoLabel = InfoLabel()
  public var zoom = Zoom()

  // MARK: - Inner types

  public struct PageIndicator {
    public var enabled = true
    public var separatorColor = UIColor.hex("3D4757")

    public var textAttributes = [
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
    public var enabled = true
    public var size = CGSize(width: 60, height: 25)
    public var text = NSLocalizedString("Close", comment: "")
    public var image: UIImage?

    public var textAttributes = [
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
    public var enabled = true
    public var size = CGSize(width: 70, height: 25)
    public var text = NSLocalizedString("Delete", comment: "")
    public var image: UIImage?

    public var textAttributes = [
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
    public var enabled = true
    public var ellipsisText = NSLocalizedString("Show more", comment: "")
    public var elipsisColor = UIColor.hex("899AB9")

    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.hex("DBDBDB")
    ]
  }

  public struct Zoom {
    public var minimumScale: CGFloat = 1.0
    public var maximumScale: CGFloat = 2.5
  }
}
