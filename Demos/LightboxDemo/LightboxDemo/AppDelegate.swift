import UIKit
import Lightbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
    }()

  lazy var viewController: UIViewController = {
    let controller = ViewController()
    return controller
    }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    let imageNames = ["photo1", "photo2", "photo3"]
    let images = imageNames.map { UIImage(named: $0)! }
    let controller = LightboxController(images: images)

    window!.rootViewController = controller
    window!.backgroundColor = UIColor.whiteColor()
    window!.makeKeyAndVisible()

    return true
  }
}
