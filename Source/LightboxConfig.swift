import UIKit

public struct LightboxConfig {

  static var config = LightboxConfig()

  public var hideStatusBar = true
  public var pageIndicator = PageIndicator()
  public var closeButton = CloseButton()
  public var deleteButton = DeleteButton()
  public var infoLabel = InfoLabel()
  public var zoom = Zoom()
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

  public init() {}

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
    public var enabled = false
    public var size = CGSize(width: 70, height: 25)
    public var text = NSLocalizedString("Delete", comment: "")
    public var image: UIImage?

    public var textAttributes = [
      NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
      NSForegroundColorAttributeName: UIColor(red:0.99, green:0.26, blue:0.18, alpha:1),
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

    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor(red:219/255, green:219/255, blue:219/255, alpha:1)
    ]
  }

  public struct Zoom {
    public var minimumScale: CGFloat = 1.0
    public var maximumScale: CGFloat = 2.5
  }
}
