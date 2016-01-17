//
//  IPaImagePreviewViewController.swift
//  PKCaculatorPro
//
//  Created by IPa Chen on 2015/12/25.
//  Copyright © 2015年 AMagicStudio. All rights reserved.
//

import UIKit

class IPaImagePreviewViewController: UIViewController,UIScrollViewDelegate,UIGestureRecognizerDelegate{
    lazy var contentScrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        let viewsDict = ["view": scrollView]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",options:NSLayoutFormatOptions(rawValue: 0),metrics:nil,views:viewsDict))
        
        scrollView.addGestureRecognizer(self.doubleTapRecognizer)
        return scrollView
    }()
    
    //    @IBOutlet var singleTapRecognizer: UITapGestureRecognizer!
    lazy var contentImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentScrollView.addSubview(imageView)
        self.imgViewWidthConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute:.NotAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.width)
        self.imgViewHeightConstraint = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.contentScrollView.bounds.height)
        
        self.imgViewLeadingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Leading, multiplier: 1, constant: 0)
        
        self.imgViewTopConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0)
        self.imgViewBottomConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0)
        
        self.imgViewTrailingConstraint = NSLayoutConstraint(item: self.contentScrollView, attribute: .Trailing, relatedBy: .Equal, toItem: imageView, attribute: .Trailing, multiplier: 1, constant: 0)
        imageView.addConstraints([self.imgViewWidthConstraint,self.imgViewHeightConstraint])

        self.contentScrollView.addConstraints([self.imgViewLeadingConstraint,self.imgViewTopConstraint,self.imgViewBottomConstraint,self.imgViewTrailingConstraint])

        
        return imageView
    }()
    lazy var doubleTapRecognizer:UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: "onZoom:")
        recognizer.numberOfTapsRequired = 2
        recognizer.cancelsTouchesInView = true
        recognizer.delaysTouchesBegan = false
        recognizer.delaysTouchesEnded = true
        recognizer.delegate = self
        return recognizer
    }()
    lazy var imgViewHeightConstraint = NSLayoutConstraint()
    lazy var imgViewWidthConstraint = NSLayoutConstraint()
    lazy var imgViewTopConstraint = NSLayoutConstraint()
    lazy var imgViewLeadingConstraint = NSLayoutConstraint()
    lazy var imgViewBottomConstraint = NSLayoutConstraint()
    lazy var imgViewTrailingConstraint = NSLayoutConstraint()
    var pageIndex:Int = 0
    var loadingImage:UIImage?
    var image:UIImage? {
        get {
            return contentImageView.image
        }
        set {
            contentImageView.image = newValue
            contentScrollView.setZoomScale(1, animated: false)
            refreshPictureImageView(contentScrollView.zoomScale)
            contentScrollView.layoutIfNeeded()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        if let loadingImage = loadingImage {
            image = loadingImage
        }
        //        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let loadingImage = loadingImage {
            image = loadingImage
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let loadingImage = loadingImage {
            image = loadingImage
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    

    
    @IBAction func onZoom(sender:UITapGestureRecognizer)
    {
        if (contentScrollView.zoomScale > 1) {
            contentScrollView.setZoomScale(1, animated: true)
        }
        else {
            let location = sender.locationInView(contentImageView)
            contentScrollView.zoomToRect(CGRect(x: location.x - 10, y: location.y - 10, width: 10, height: 10), animated: true)
        }
        
    }
    
    func refreshPictureImageView(scale:CGFloat)
    {
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        
        var imageWidth:CGFloat = 1
        var imageHeight:CGFloat = 1
        guard let image = image else {
            return
            
        }
        imageWidth = image.size.width
        imageHeight = image.size.height
        let ratio = imageWidth / imageHeight
        let viewRatio = viewWidth / viewHeight
        
        var imageViewWidth:CGFloat
        var imageViewHeight:CGFloat
        if ratio >= viewRatio {
            imageViewWidth = viewWidth * scale
            imageViewHeight = imageViewWidth / ratio
            contentScrollView.contentInset = UIEdgeInsets(top: max(0,(viewHeight - imageViewHeight) * 0.5), left: 0, bottom: 0, right: 0)
//            imgViewLeadingConstraint.constant = 0
//            imgViewTopConstraint.constant = -max(0,(viewHeight - imageViewHeight) * 0.5)
        }
        else {
            imageViewHeight = viewHeight * scale
            imageViewWidth = imageViewHeight * ratio
            contentScrollView.contentInset = UIEdgeInsets(top: 0, left:(viewWidth - imageViewWidth) * 0.5, bottom: 0, right: 0)
//            imgViewTopConstraint.constant = 0
//            imgViewLeadingConstraint.constant = -max(0,(viewWidth - imageViewWidth) * 0.5)
        }
        imgViewWidthConstraint.constant = (imageViewWidth / scale)
        imgViewHeightConstraint.constant = (imageViewHeight / scale)

    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    //MARK:UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        refreshPictureImageView(scrollView.zoomScale)
    }
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        UIView.animateWithDuration(0.3, animations: {
            self.contentScrollView.layoutIfNeeded()
        })
    }
    
}
