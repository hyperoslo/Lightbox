import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var controller: UINavigationController = UINavigationController(rootViewController: ViewController())

  var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow()
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}

