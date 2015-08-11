import UIKit

extension LightboxController: UICollectionViewDataSource {

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cellIdentifier = LightboxViewCell.reuseIdentifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! LightboxViewCell
    let image = images[indexPath.row]
    let config = LightboxConfig.sharedInstance.config

    cell.parentViewController = self
    cell.setupTransitionManager()

    if let imageString = image as? String {
      if let imageURL = NSURL(string: imageString) where config.remoteImages {
        config.loadImage(
          imageView: cell.lightboxView.imageView, URL: imageURL) { error in
            if error == nil { cell.lightboxView.updateViewLayout() }
        }
      } else {
        cell.lightboxView.imageView.image = UIImage(named: imageString)
        cell.lightboxView.updateViewLayout()
      }
    } else if let image = image as? UIImage {
      cell.lightboxView.imageView.image = image
      cell.lightboxView.updateViewLayout()
    }

    return cell
  }
}
