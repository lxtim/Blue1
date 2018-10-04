//
//  PageViewController.swift
//  Blue
//
//  Created by Tim Schönenberger on 06.07.18.
//  Copyright © 2018 Tim. All rights reserved.
//


//Responsible for swiping of viewcontrollers




import UIKit
import Firebase

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageControl = UIPageControl()
    var ref: DatabaseReference = Database.database().reference()
    
    // MARK: UIPageViewControllerDataSource
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [Object(FeedViewController.self),
                Object(ProfileViewController.self)]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        configurePageControl()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = .white
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl.frame = CGRect(x: 0,y: self.view.bounds.size.height - 50,width: self.view.bounds.width,height: 50)
        self.pageControl.isUserInteractionEnabled = false
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.translatesAutoresizingMaskIntoConstraints =  false
        pageControl = UIPageControl(frame: CGRect(x: 0,y: self.view.bounds.size.height - 50,width: self.view.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.red
        self.pageControl.currentPageIndicatorTintColor = UIColor.gray
        self.view.insertSubview(pageControl, at: 10)
    }
    
    
    // MARK: Delegate methords
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
