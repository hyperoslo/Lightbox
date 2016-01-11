import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var controller: UIViewController = ViewController()

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow()
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}

