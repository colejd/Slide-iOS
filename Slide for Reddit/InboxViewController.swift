//
//  InboxViewController.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 1/23/17.
//  Copyright © 2017 Haptic Apps. All rights reserved.
//

import Anchorage
import MaterialComponents.MaterialTabs
import reddift
import UIKit

class InboxViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var content: [MessageWhere] = []
    var isReload = false
    var session: Session?

    var vCs: [UIViewController] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ColorUtil.theme.isLight && SettingValues.reduceColor {
            return .default
        } else {
            return .lightContent
        }
    }

    public init() {
        self.session = (UIApplication.shared.delegate as! AppDelegate).session
        self.content = InboxViewController.doDefault()

        for place in content {
            vCs.append(ContentListingViewController.init(dataSource: InboxContributionLoader(whereContent: place)))
        }
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func doDefault() -> [MessageWhere] {
        return [MessageWhere.inbox, MessageWhere.messages, MessageWhere.unread]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
        self.title = "Inbox"
        UIApplication.shared.applicationIconBadgeNumber = 0
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupBaseBarColors()
        let edit = UIButton.init(type: .custom)
        edit.setImage(UIImage(sfString: SFSymbol.pencil, overrideString: "edit")?.navIcon(), for: UIControl.State.normal)
        edit.addTarget(self, action: #selector(self.new(_:)), for: UIControl.Event.touchUpInside)
        edit.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let editB = UIBarButtonItem.init(customView: edit)

        let read = UIButton.init(type: .custom)
        read.setImage(UIImage(sfString: .eyeFill, overrideString: "seen")?.navIcon(), for: UIControl.State.normal)
        read.addTarget(self, action: #selector(self.read(_:)), for: UIControl.Event.touchUpInside)
        read.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let readB = UIBarButtonItem.init(customView: read)

        navigationItem.rightBarButtonItems = [editB, readB]
    }

    @objc func new(_ sender: AnyObject) {
        VCPresenter.presentAlert(TapBehindModalViewController.init(rootViewController: ReplyViewController.init(completion: {(_) in
            DispatchQueue.main.async(execute: { () -> Void in
                BannerUtil.makeBanner(text: "Message sent!", seconds: 3, context: self)
            })
        })), parentVC: self)
    }

    @objc func read(_ sender: AnyObject) {
        do {
            try session?.markAllMessagesAsRead(completion: { (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        BannerUtil.makeBanner(text: "All messages marked as read", seconds: 5, context: self)
                    }
                default:
                    break
                }
            })
        } catch {

        }
    }

    var time: Double = 0

    func close() {
        self.navigationController?.popViewController(animated: true)
    }

    var tabBar = MDCTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = navigationController {
            if navigationController.viewControllers.count == 1 {
                navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .done, target: self, action: #selector(closeButtonPressed))
            }
        }

        var items: [String] = []
        for i in content {
            items.append(i.description)
        }

        tabBar = MDCTabBar.init(frame: CGRect.zero)
        tabBar.backgroundColor = ColorUtil.getColorForSub(sub: "", true)
        tabBar.itemAppearance = .titles
        tabBar.selectedItemTintColor = (SettingValues.reduceColor ? ColorUtil.theme.fontColor : UIColor.white)
        tabBar.unselectedItemTintColor = (SettingValues.reduceColor ? ColorUtil.theme.fontColor : UIColor.white).withAlphaComponent(0.45)

        tabBar.items = content.enumerated().map { index, source in
            return UITabBarItem(title: source.description, image: nil, tag: index)
        }
        tabBar.delegate = self
        tabBar.inkColor = UIColor.clear
        tabBar.selectedItem = tabBar.items[0]
        tabBar.tintColor = ColorUtil.accentColorForSub(sub: "NONE")

        self.view.addSubview(tabBar)
        tabBar.heightAnchor == 48
        
        self.edgesForExtendedLayout = UIRectEdge.all
    
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false

        var isModal13 = false
        if #available(iOS 13, *), (self.navigationController?.viewControllers[0] == self) {
            isModal13 = true
        }
        tabBar.topAnchor == self.view.topAnchor + (self.navigationController?.navigationBar.frame.size.height ?? 64) + (isModal13 ? 0 : UIApplication.shared.statusBarFrame.height)

        tabBar.horizontalAnchors == self.view.horizontalAnchors
        tabBar.sizeToFit()
        
        time = History.getInboxSeen()
        History.inboxSeen()
        view.backgroundColor = ColorUtil.theme.backgroundColor
        // set up style before super view did load is executed
        // -

        self.dataSource = self
        self.delegate = self

        self.navigationController?.view.backgroundColor = UIColor.clear
        let firstViewController = vCs[0]

        for view in view.subviews {
            if view is UIScrollView {
                (view as! UIScrollView).delegate = self
                break
            }
        }

        if self.navigationController?.interactivePopGestureRecognizer != nil {
            for view in view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)
                }
            }
        }

        setViewControllers([firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)

    }

    var selected = false

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        let page = vCs.index(of: self.viewControllers!.first!)

        if !selected {
            tabBar.setSelectedItem(tabBar.items[page!], animated: true)
        }
        selected = false
        
        currentIndex = page!

    }

    var currentIndex = 0
    var lastPosition: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastPosition = scrollView.contentOffset.x

        if currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentIndex == vCs.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }

    //From https://stackoverflow.com/a/25167681/3697225
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if currentIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentIndex == vCs.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vCs.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard vCs.count > previousIndex else {
            return nil
        }

        return vCs[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vCs.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = vCs.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return vCs[nextIndex]
    }

}

extension InboxViewController: MDCTabBarDelegate {

    func tabBar(_ tabBar: MDCTabBar, didSelect item: UITabBarItem) {
        let firstViewController = vCs[tabBar.items.index(of: item)!]
        currentIndex = tabBar.items.index(of: item)!
        setViewControllers([firstViewController],
                           direction: .forward,
                           animated: false,
                           completion: nil)
        
    }
}

// MARK: - Actions
extension InboxViewController {
    @objc func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
