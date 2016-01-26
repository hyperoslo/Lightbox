import UIKit

public struct LightboxConfig {

  static var config = LightboxConfig()

  public var hideStatusBar = true
  public var backgroundColor = UIColor.clearColor()
  public var pageIndicator = PageIndicator()
  public var closeButton = CloseButton()
  public var deleteButton = DeleteButton()
  public var zoom = Zoom()
  public var remoteImages = false
  public var spacing: CGFloat = 20

  public typealias LoadImageCompletion = (error: NSError?) -> Void

  public var loadImage: (imageView: UIImageView, URL: NSURL, completion: LoadImageCompletion?) -> Void = {
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

  public init() { }

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
    public var image: UIImage?
  }

  public struct DeleteButton {
    public var enabled = true
    public var alpha: CGFloat = 0
    public var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor(red:0.99, green:0.26, blue:0.18, alpha:1),
      NSParagraphStyleAttributeName: {
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        return style
        }()
    ]
    public var size = CGSize(width: 70, height: 25)
    public var text = NSLocalizedString("Delete", comment: "")
    public var image: UIImage?
  }

  public struct Zoom {
    public var minimumScale: CGFloat = 1.0
    public var maximumScale: CGFloat = 3.0
  }
}
