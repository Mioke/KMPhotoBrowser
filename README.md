# KMPhotoBrowser
A tool for showing photos.

### Demo
![ScreenShot](https://github.com/Mioke/KMPhotoBrowser/blob/master/KMPhotoBrowserDemo/DemoGif/KMPhotoBrowserDemo2.gif)

### Usage

 1. Download the zip to your computer, copy the `KMPhotoBrowser` file into you project. 
 2. Import [SDWebImage](https://github.com/rs/SDWebImage) into your project.

#### KMPhotoBrowserView

`KMPhotoBrowserView` is a container that shows photos receive from a array of photos or photo's url array. You can define the frame the container, but the height will automaticaly changed when you set the photos. The photo's width is one third of the container's width.
And you can set different value of gap between two photos by setting the type of `KMPhotoBrowserViewType.AutoComposing(gapWidth: x)`(the `x` means the width of the gap).

```swift
let imageURLs: [String] = [...]

let photoView = KMPhotoBrowserView(frame: CGRectMake(15, 100, UIScreen.mainScreen().bounds.size.width - 90, 0), imageURLs: imageURLs, type: KMPhotoBrowserViewType.AutoComposing(gapWidth: 5))

// or 
// let images: [UIImage] = [...]
// photoView.setContentWithImages(self.images, type: KMPhotoBrowserViewType.AutoComposing(gapWidth: 5))

photoView.delegate = self
self.view.addSubview(photoView)
```
Conform to protocol `KMPhotoBrowserViewDelegate` to capture the click action:

```swift
extension ViewController: KMPhotoBrowserViewDelegate {
    func photoBroswerView(view: KMPhotoBrowserView, clickImageAtIndex index: Int) {
        // do something
    }
}
```

#### KMPhotoBrowserViewController

`KMPhotoBrowserViewController` is a view controller shows the photos one by one.

```swift
let vc = KMPhotoBrowserViewController()
vc.imageURLs = self.imageURLs
/* or vc.images = self.images */

// Tap to close the view controller
vc.clickForBack = true
vc.delegate = self
        
vc.currentIndex = index
self.presentViewController(vc, animated: true, completion: nil)
```

By default, the right navigation item is `delete`, conform to the protocol `KMPhotoBrowserDelegate` to capture the click action:

```swift
extension ViewController: KMPhotoBrowserDelegate {
    
    func photoBrowserVC(vc: KMPhotoBrowserViewController, deleteImageAtIndex index: Int) {
        // do something
    }
}
```

Also, you can customized in your own way using `PBVCRightNaviItemOption` like:

```swift 
let vc = KMPhotoBrowserViewController()

// some code...

vc.rightNavigationItemOption = KMPhotoBrowserViewController.PBVCRightNaviItemOption(icon: UIImage(named: "xxx"), text: attributeString) { (photoBrowserVC) -> Void in
  // do the things when click the item
}
self.presentViewController(vc, animated: true, completion: nil)
```

In objc, using `rightNavigationItemOption_oc(NSDictionary)` instead. The key is the same as the properties' name in struct `PBVCRightNaviItemOption`.

### Contact

You can open an issue when find bugs.

# Licence
KMPhotoBrowser is under the MIT Licence, see the LICENCE file for details.
