//
//  NewsfeedViewController.swift
//  Calendar
//
//  Created by User on 06.12.2023.
//  Copyright © 2023 Николай Борисов. All rights reserved.
//

import Foundation

protocol NewsfeedViewControllerProtocol: AnyObject {
    func reloadData()
    func reloadFilterData()
    
    func present(vc: UIViewController)
    
}

class NewsfeedViewController: UIViewController {
    let GROUPING_SCROLLING_VIEW_TAG = 600
    
    var topGroupingScroller: UIScrollView = UIScrollView.init(frame: .zero)
    var tableView: UITableView = UITableView(frame: .zero)
    var mainView: UIView = UIView()
    var tableHeader: UIView = UIView()
    
    var presenter: NewsfeedPresenter = NewsfeedPresenterImpl()
    
    lazy var counterContainer: UIView = {
        let view = UIView()
        
        view.addSubview(self.counterLabel)
        view.frame = CGRect(x: 0, y: 0, width: self.counterLabel.bounds.width, height: 28)
        
        return view
    }()
    
    lazy var counterLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13.0)
        label.textColor = .secondaryLabel
        label.backgroundColor = .init(dynamicProvider: { _ in
            return .tertiarySystemFill
        })
        
        let counterValue = self.presenter.getItemCount()
        label.text = "\(counterValue)"
        label.sizeToFit()
        
        label.frame = CGRect(x: 4, y: 0, width: 16+Int(ceilf(Float(label.bounds.width))), height: 28)
        
        label.clipsToBounds = true
        label.cornerRadius = 8.0
        label.layer.cornerCurve = .continuous
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: mainView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mainView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        mainView.backgroundColor = .white
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        //Header
        prepareHeaderForGroup(header: tableHeader)
        tableHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64)
        tableHeader.isHidden = true
        
        //tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height:CGFLOAT_MIN)))
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
        self.tableView.register(NewsfeedCell.self, forCellReuseIdentifier: "NewsfeedCell")
        
        mainView.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self.tableView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.tableView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.tableView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.tableView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        
        //Presenter
        self.presenter.attachView(self)
        
        reloadFilterData()
        setupNavigationItem()
  
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom != .pad  {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.restrictRotation = .portrait
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.restrictRotation = .all
            }
        }
        
        self.navigationItem.searchController = getSearchController()
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        reloadFilterData()
        setupNavigationItem()
  
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.presenter.setSearchText(nil)
        self.reloadData()
        
        
        self.searchController = nil
        self.navigationItem.searchController = nil
    }
    
    func reloadCounter() {
        let counterValue = self.presenter.getItemCount()
        counterLabel.text = "\(counterValue)"
        counterLabel.sizeToFit()
        
        counterLabel.frame = CGRect(x: 4, y: 0, width:16+Int(ceilf(Float(counterLabel.bounds.width))), height: 28)
        
        counterLabel.clipsToBounds = true
        counterLabel.cornerRadius = 8.0
        counterLabel.layer.cornerCurve = .continuous
        counterLabel.isUserInteractionEnabled = false
        
        counterContainer.frame = CGRect(x: 0, y: 0, width: self.counterLabel.bounds.width, height: 28)
    }
    
    func setupNavigationItem() {
        self.title = "Newsfeed"
        
        let counterItem = UIBarButtonItem(customView: self.counterContainer)
        navigationItem.rightBarButtonItem = counterItem
        
        navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func prepareHeaderForGroup(header: UIView) {
        self.topGroupingScroller.delegate = self
        self.topGroupingScroller.showsHorizontalScrollIndicator = false
        self.topGroupingScroller.tag = GROUPING_SCROLLING_VIEW_TAG
        self.topGroupingScroller.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(self.topGroupingScroller)
        self.topGroupingScroller.frame = CGRect(x: 0, y: 0, width: header.bounds.size.width, height: 64)
        
        NSLayoutConstraint(item: self.topGroupingScroller, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.topGroupingScroller, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: self.topGroupingScroller, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.topGroupingScroller, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: header, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 16).isActive = true
        
        header.backgroundColor = .white
    }
    
    func reloadFilterData() {
        self.topGroupingScroller.subviews.forEach({$0.removeFromSuperview()})
        
        self.topGroupingScroller.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.topGroupingScroller.fade = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.topGroupingScroller.contentSize = CGSize(width: 0, height: self.topGroupingScroller.bounds.size.height)
        self.topGroupingScroller.scrollsToTop = false
        
        var x: Double = 0.0;
        
        self.presenter.getFilters().forEach { item in
            //Создадим вьюху
            let groupingView = UIControl()
            groupingView.cornerRadius = 8.0
            groupingView.layer.cornerCurve = .continuous
            groupingView.clipsToBounds = true
            groupingView.backgroundColor = .white
            groupingView.layer.borderColor = UIColor.systemBlue.cgColor
            groupingView.layer.borderWidth = 1
            
            let label = UILabel()
            
            switch item {
            case .type:
                if let type = self.presenter.getFilterType() {
                    groupingView.backgroundColor = .systemBlue
                    
                    label.text = type.title.capitalized
                    label.font = .systemFont(ofSize: 13.0, weight: .medium)
                    label.textColor = .white
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .white
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
                    button.bk_addEventHandler({ sender in
                        self.presenter.setFilterType(nil)
                    }, for: .touchUpInside)
                    
                    groupingView.addSubview(button)
                    groupingView.bk_addEventHandler({ sender in
                        self.presenter.setFilterType(nil)
                    }, for: .touchUpInside)
                
                    x = x + width + 8
                } else {
                    label.text = item.title
                    label.font = .systemFont(ofSize: 13.0, weight: .regular)
                    label.textColor = .systemBlue
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .systemBlue
                    button.addTarget(self, action: #selector(showTypeMenu), for: .touchUpInside)
                    
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
                    
                    groupingView.addSubview(button)
                    groupingView.addTarget(self, action: #selector(showTypeMenu), for: .touchUpInside)
                    
                    x = x + width + 8
                }
                break
            case .author:
                if let author = self.presenter.getAuthorFilter() {
                    groupingView.backgroundColor = .systemBlue
                    
                    label.text = author.fullName().capitalized
                    label.font = .systemFont(ofSize: 13.0, weight: .medium)
                    label.textColor = .white
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .white
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
                    button.bk_addEventHandler({ sender in
                        self.presenter.authorDidTapped(person: nil)
                    }, for: .touchUpInside)
                    
                    groupingView.addSubview(button)
                    groupingView.bk_addEventHandler({ sender in
                        self.presenter.authorDidTapped(person: nil)
                    }, for: .touchUpInside)
                    
                    x = x + width + 8
                } else {
                    label.text =  item.title
                    label.font = .systemFont(ofSize: 13.0, weight: .regular)
                    label.textColor = .systemBlue
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .systemBlue
                    button.addTarget(self, action: #selector(showAuthorsMenu), for: .touchUpInside)
                    
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
                    
                    groupingView.addSubview(button)
                    groupingView.addTarget(self, action: #selector(showAuthorsMenu), for: .touchUpInside)
                    
                    x = x + width + 8
                }
                break
            case .tag:
                if let tag = self.presenter.getTagsFilter() {
                    groupingView.backgroundColor = .systemBlue
                    
                    label.text = tag.tag_title.capitalized
                    label.font = .systemFont(ofSize: 13.0, weight: .medium)
                    label.textColor = .white
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .white
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
                    button.bk_addEventHandler({ sender in
                        self.presenter.tagDidTapped(tag: nil)
                    }, for: .touchUpInside)
                    
                    groupingView.addSubview(button)
                    groupingView.bk_addEventHandler({ sender in
                        self.presenter.tagDidTapped(tag: nil)
                    }, for: .touchUpInside)
                    
                    x = x + width + 8
                } else {
                    label.text =  item.title
                    label.font = .systemFont(ofSize: 13.0, weight: .regular)
                    label.textColor = .systemBlue
                    label.textAlignment = .center
                    label.sizeToFit()
                    
                    let width_label = ceilf(Float(label.bounds.size.width))
                    let width: Double = Double(12 + width_label + 8 + 22)
                    
                    groupingView.frame = CGRect(origin: CGPoint(x: x, y: 0), size: CGSize(width: width, height: 32.0))
                    
                    self.topGroupingScroller.addSubview(groupingView)
                    
                    label.frame = CGRect(origin: CGPoint(x: 12, y: 0), size: CGSize(width: CGFloat(width_label), height: groupingView.bounds.size.height))
                    groupingView.addSubview(label)
                    
                    //Создадим кнопку
                    let button: ButtonMoreTapArea = ButtonMoreTapArea(type: .system)
                    button.frame = CGRect(origin: CGPoint(x: groupingView.bounds.width - 32, y: 0), size: CGSize(width: 32, height: 32))
                    button.autoresizingMask = .flexibleLeftMargin
                    button.tintColor = .systemBlue
                    button.addTarget(self, action: #selector(showTagMenu), for: .touchUpInside)
                    
                    
                    let config = UIImage.SymbolConfiguration(pointSize: 12)
                    button.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
                    
                    groupingView.addSubview(button)
                    groupingView.addTarget(self, action: #selector(showTagMenu), for: .touchUpInside)
                    
                    x = x + width + 8
                }
                break
            }
        }
        
        x = x - 4
        
        if (x > 8)
        {
            x = x - 8
        }
        
        self.topGroupingScroller.contentSize = CGSize(width: x, height: self.topGroupingScroller.bounds.size.height)
        self.topGroupingScroller.contentOffset = CGPoint(x: -16, y: 0)
    }

    @objc
    private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                
            }
        }
    }
    
    func openTask(at indexPath: IndexPath) {
        guard let model = presenter.getItem(at: indexPath.item) else { return }
        guard let managerID = presenter.getSelectedManager()?.id else { return }
        
        let taskViewController = TaskViewController(task: model.task)
        taskViewController.selectedDate = model.task.startDate
        taskViewController.managerID = NSNumber(value: managerID)
        
        self.navigationController?.pushViewController(taskViewController, animated: true)
    }
    
    typealias ObjCMenuBlock = @convention(block) (NSDictionary) -> Void
   
    @objc 
    private func showTagMenu(sender: Any) {
        var mutableContent = [[String: Any]]()
        let tags = self.presenter.getTags()
        tags.forEach({ item in
            
            let tagDidTapped: ObjCMenuBlock = { menuItem in
                self.presenter.tagDidTapped(tag: item)
            }
            
            let objCBlock: AnyObject = unsafeBitCast(tagDidTapped, to: AnyObject.self)
            
            let dictionary = ["title": item.tag_title!,
                              "action": objCBlock]
            
            mutableContent.append(dictionary)
        })
        
        let menuContent = mutableContent
        
        DSTMenuKit(andShowFromSender: sender, andDataArray: menuContent, useArrow: true, parameters: nil)
    }
    
    @objc
    private func showAuthorsMenu(sender: Any) {
         var mutableContent = [[String: Any]]()
        let people = self.presenter.getAuthors().sorted(by: {$0.fullName() < $1.fullName()})
         people.forEach({ item in
             
             let didTapped: ObjCMenuBlock = { menuItem in
                 self.presenter.authorDidTapped(person: item)
             }
             
             let objCBlock: AnyObject = unsafeBitCast(didTapped, to: AnyObject.self)
             
             let dictionary = ["title": item.fullName()!,
                               "action": objCBlock]
             
             mutableContent.append(dictionary)
         })
         
         let menuContent = mutableContent
         
         DSTMenuKit(andShowFromSender: sender, andDataArray: menuContent, useArrow: true, parameters: nil)
     }
    
    @objc
    private func showTypeMenu(sender: Any) {
        var mutableContent = [[String: Any]]()
        let items = NewsfeedType.allCasses
        items.forEach({ item in
            
            let didTapped: ObjCMenuBlock = { menuItem in
                self.presenter.setFilterType(item)
            }
            
            let objCBlock: AnyObject = unsafeBitCast(didTapped, to: AnyObject.self)
            
            let dictionary = ["title": item.title,
                              "action": objCBlock]
            
            mutableContent.append(dictionary)
        })
        
        let menuContent = mutableContent
        
        DSTMenuKit(andShowFromSender: sender, andDataArray: menuContent, useArrow: true, parameters: nil)
    }
    
    func getSearchController() -> UISearchController? {
        guard self.searchController == nil else { return self.searchController }
        
        let search = UISearchController(searchResultsController: nil)
        
        search.delegate = self
        search.searchBar.barStyle = .default
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.frame = CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 56))
        search.searchBar.delegate = self
        
        search.searchBar.placeholder = "Search"
        search.searchBar.autocapitalizationType = .sentences
        search.searchBar.returnKeyType = .done
        
        search.searchBar.backgroundColor = .white
        self.searchController = search
        
        return self.searchController
    }
}

extension NewsfeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NewsfeedCell(style: .default, reuseIdentifier: nil)
        
        guard let model = presenter.getItem(at: indexPath.item) else { return cell }
        let task = model.task
        
        cell.taskName.text = task.eventTitle
        
        if let datString = task.getDisplayingDateAndTimeString(), !datString.isEmpty {
            cell.setSecondLine(text: datString)
        }
        
        if let recString = task.getDisplayingRecurringString(), !recString.isEmpty {
            cell.setThirdLine(text: recString)
        }
        
        cell.type = model.type
        
        switch model.type {
        case .create:
            cell.feedFirstLine.text = "Added by "
            
            if let fullName = task.authorPerson.fullName() {
                cell.feedFirstLine.text = "Added by \(fullName)"
            }
            
            if let date = task.date.toDate(format: "yyyy-MM-dd HH:mm:ss") {
                let dateString = date.toString(format:"MMM d, yyyy")
                let timeString = date.toString(format:"HH:mm")
                cell.feedSecondLine.text = "on \(dateString) at \(timeString)"
            }
            
            break
        case .changeStatus:
            let mutableString = NSMutableAttributedString()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6.0
            
            if let statusBD = Status.allObjects().objectsWhere("ID = \(model.oldStatusID)", args:getVaList([])).firstObject() {
                
                let imageAttach = NSTextAttachment()
                let config = UIImage.SymbolConfiguration(pointSize: 13.0)
                imageAttach.image = UIImage(systemName: "arrow.right", withConfiguration: config)?.withTintColor(.secondaryLabel)
                
                mutableString.append(NSAttributedString(string: statusBD.statusName,
                                                        attributes: [             .foregroundColor: UIColor.label,
                                                                                  .font: UIFont.systemFont(ofSize: 13.0),
                                                                                  .paragraphStyle: paragraphStyle]))
                
                mutableString.append(NSAttributedString(string: "   ",
                                                        attributes: [.foregroundColor: UIColor.label,
                                                                     .font: UIFont.systemFont(ofSize: 13.0),
                                                                     .paragraphStyle: paragraphStyle]))
                mutableString.append(NSAttributedString(attachment: imageAttach))
                mutableString.append(NSAttributedString(string: "   ",
                                                        attributes: [.foregroundColor: UIColor.label,
                                                                     .font: UIFont.systemFont(ofSize: 13.0),
                                                                     .paragraphStyle: paragraphStyle]))
                
            }
            
            
            if let statusBD = Status.allObjects().objectsWhere("ID = \(model.newStatusID)", args:getVaList([])).firstObject() {

                mutableString.append(NSAttributedString(string: statusBD.statusName,
                                                        attributes: [.foregroundColor: UIColor.label,
                                                                     .font: UIFont.systemFont(ofSize: 13.0),
                                                                     .paragraphStyle: paragraphStyle]))
            }
            
            cell.feedFirstLine.attributedText = mutableString
            
            cell.feedSecondLine.text = "Changed by "
            
            if let fullName = task.authorPerson.fullName() {
                cell.feedSecondLine.text = "Changed by \(fullName)"
            }
              
            let date = model.updateAt
    
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dateString = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            cell.feedSecondLine.text = "\(cell.feedSecondLine.text ?? "") on \(dateString) at \(timeString)"
            
            break
        }
        
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openTask(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableHeader.frame.height
    }
}

extension NewsfeedViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.setSearchText(searchText)
        self.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.presenter.setSearchText(nil)
        searchBar.resignFirstResponder()
        self.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension NewsfeedViewController: NewsfeedViewControllerProtocol {
    func reloadData() {
        
        self.tableView.reloadData()
        self.tableHeader.isHidden = false
        
        view.layoutIfNeeded()
        reloadCounter()
    }
    
    func present(vc: UIViewController) {
        self.present(vc, animated: true)
    }
}
