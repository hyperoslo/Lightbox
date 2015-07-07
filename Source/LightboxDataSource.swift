import UIKit

extension LightboxController: UICollectionViewDataSource {

  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cellIdentifier = LightboxViewCell.reuseIdentifier
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! LightboxViewCell
    let image = images[indexPath.row]
    let config = LightboxConfig.sharedInstance.config

    if config.remoteImages {
      if let imageURL = NSURL(string: image) {
        config.loadImage(
          imageView: cell.lightboxView.imageView, URL: imageURL) {
            error in
            if error == nil {
              cell.lightboxView.updateViewLayout()
            }
          }
      }
    } else {
      cell.lightboxView.imageView.image = UIImage(named: image)
      cell.lightboxView.updateViewLayout()
    }

    return cell
  }
}
