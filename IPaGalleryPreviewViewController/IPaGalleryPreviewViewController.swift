//
//  IPaGalleryPreviewViewController.swift
//  PKCaculatorPro
//
//  Created by IPa Chen on 2015/12/25.
//  Copyright © 2015年 AMagicStudio. All rights reserved.
//

import UIKit
protocol IPaGalleryPreviewViewControllerDelegate {
    func numberOfImagesForGallery(_ galleryViewController:IPaGalleryPreviewViewController) -> Int
    func imageForGallery(_ galleryViewController:IPaGalleryPreviewViewController,index:Int) -> UIImage?
}
class IPaGalleryPreviewViewController: UIViewController , UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIGestureRecognizerDelegate {
    lazy var pageViewController:UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.backgroundColor = UIColor.black
        let previewViewController = self.previewViewControllers.first!
        previewViewController.pageIndex = self.currentIndex
        previewViewController.loadingImage = self.delegate?.imageForGallery(self, index: self.currentIndex)
        pageViewController.setViewControllers([previewViewController], direction:.forward, animated: false, completion: nil)
        
        
        return pageViewController
    }()
    var delegate:IPaGalleryPreviewViewControllerDelegate?
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(IPaGalleryPreviewViewController.onTap(_:)))
        recognizer.delegate = self
        return recognizer
    }()
    lazy var previewViewControllers:[IPaImagePreviewViewController] = {

        let previewViewController = IPaImagePreviewViewController()
        let previewViewController2 = IPaImagePreviewViewController()
        self.tapGestureRecognizer.require(toFail: previewViewController.doubleTapRecognizer)
        self.tapGestureRecognizer.require(toFail: previewViewController2.doubleTapRecognizer)
        return [previewViewController,previewViewController2]
    }()
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapGestureRecognizer)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        let viewsDict:[String:UIView] = ["view": pageViewController.view]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        let numberCount = delegate!.numberOfImagesForGallery(self)
        var direction:UIPageViewControllerNavigationDirection = .forward
        if currentIndex >= numberCount {
            currentIndex = numberCount - 1
            direction = .reverse
        }
        if currentIndex < 0 {
            currentIndex = 0
        }
        
        let viewController = pageViewController.viewControllers!.first! as! IPaImagePreviewViewController
        var nextViewController:IPaImagePreviewViewController
        let index = previewViewControllers.index(of: viewController)!
        if index == 0 {
            nextViewController = previewViewControllers.last!
        }
        else {
            nextViewController = previewViewControllers.first!
        }
        nextViewController.pageIndex = currentIndex
        nextViewController.loadingImage = delegate?.imageForGallery(self, index: currentIndex)
//        if let loadingImage = nextViewController.loadingImage {
//            nextViewController.image = loadingImage
//        }
        pageViewController.setViewControllers([nextViewController], direction: direction, animated: true, completion: nil)
    }
    @IBAction func onTap(_ sender: AnyObject) {
        onSwitchNavigationBar()
    }
    func onSwitchNavigationBar() {
        guard let navigationController = self.navigationController else {
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            
            
            navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
            }, completion: {
                finished in
                self.setNeedsStatusBarAppearanceUpdate()
        })
        //        UIView.animateWithDuration(0.3, animations: {
        //            self.navigationController?.setNavigationBarHidden(!self.navigationController?.navigationBarHidden, animated: true)
        //            }, completion: {
        //                finished in
        //                self.setNeedsStatusBarAppearanceUpdate()
        //        })
    }
    
    //MARK : UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        var beforeViewController:IPaImagePreviewViewController?
        if previewViewController.pageIndex == 0 {
            return nil
        }
        else {
            if let index = previewViewControllers.index(of: previewViewController) {
                if index == 0 {
                    beforeViewController = previewViewControllers.last
                }
                else {
                    beforeViewController = previewViewControllers.first
                }
                let index = previewViewController.pageIndex - 1
                beforeViewController!.pageIndex = index
                beforeViewController!.loadingImage = delegate?.imageForGallery(self, index: index)

                return beforeViewController
            }
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let previewViewController = viewController as! IPaImagePreviewViewController
        var afterViewController:IPaImagePreviewViewController?
        let numberCount = delegate!.numberOfImagesForGallery(self)
        if previewViewController.pageIndex == (numberCount - 1) {
            return nil
        }
        else {
            if let index = previewViewControllers.index(of: previewViewController) {
                if index == 0 {
                    afterViewController = previewViewControllers.last
                }
                else {
                    afterViewController = previewViewControllers.first
                }
                let index = previewViewController.pageIndex + 1
                afterViewController!.pageIndex = index
                afterViewController!.loadingImage = delegate?.imageForGallery(self, index: index)
                return afterViewController
            }
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let viewController = pageViewController.viewControllers!.first! as! IPaImagePreviewViewController
            currentIndex = viewController.pageIndex
        }
    }
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
