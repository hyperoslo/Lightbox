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

  public var infoLabel = InfoLabel()


  public struct InfoLabel {
    public var enabled = true
    public var ellipsisText = NSLocalizedString("Show more", comment: "")
    public var elipsisColor = UIColor.hex("899AB9")

    public var textAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(12),
      NSForegroundColorAttributeName: UIColor.hex("DBDBDB")
    ]
  }
}
