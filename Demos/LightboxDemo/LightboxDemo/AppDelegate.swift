import UIKit

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

    window!.rootViewController = viewController
    window!.backgroundColor = UIColor.whiteColor()
    window!.makeKeyAndVisible()

    return true
  }
}
