//
//  SelectUserController.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 09.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SelectUserController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    private let nextButton = UIButton()
    var viewModel: SelectUserViewModel!
    private let bag = DisposeBag()
    
    //MARK: - Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableViewRefreshControll()
        bindViewModel()
    }
    
    //MARK: - Bind ui
    
    private func configureNavigationBar() {
        navigationItem.title = "Select Users"
        
        nextButton.setTitle("Next", for: .normal)
        updateNextButtonState(enabled: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton)
    }
    
    private func updateNextButtonState(enabled: Bool) {
        nextButton.setTitleColor(enabled ? .white : .gray, for: .normal)
        nextButton.isUserInteractionEnabled = enabled
    }
    
    private func configureTableViewRefreshControll() {
        tableView.refreshControl = UIRefreshControl()
    }
    
    //MARK: - Bind rx
    
    private func bindViewModel() {
        viewModel = SelectUserViewModel(dependencies: SelectUserViewModel.Dependencies(api: GitHubApi(), navigator: SelectUserNavigator(navigationController: navigationController ?? UINavigationController())))
        
        let removeFromSelectedButtonClicked = PublishSubject<Int>()
        
        let paginationTrigger = tableView.rx.contentOffset
            .filter {
                return $0.y > self.tableView.contentSize.height - (self.tableView.frame.height * 2)
            }
            .asObservable()
        
        let selectedTrigger = tableView.rx.itemSelected.map({ index -> Int in
            return index.row
        })
        .asDriver(onErrorJustReturn: 0)
                
        let refreshTrigger = tableView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let nextButtonClicked = nextButton.rx.controlEvent(.touchUpInside)
            .asDriver()
        
        let trigger = Driver.merge(rx.viewWillAppear.asDriver(), refreshTrigger)
        
        let input = SelectUserViewModel.Input(trigger: trigger,
                                              selectedTrigger: selectedTrigger,
                                              removeSelectedTrigger: removeFromSelectedButtonClicked ,
                                              paginationTrigger: paginationTrigger,
                                              nextButtonClicked: nextButtonClicked)
        
        let output = viewModel.transform(input: input)
        
        output.users
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: UserCell.self), cellType: UserCell.self)) { (row, element, cell) in
                cell.configure(with: element)
            }
            .disposed(by: bag)
        
        output.selectedUsers
            .asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: String(describing: SelectedUserCell.self), cellType: SelectedUserCell.self)) { (row, element, cell) in
                cell.configure(with: element)
                cell.bindViewModel(row: row, deleteButtonClicked: removeFromSelectedButtonClicked)
            }
            .disposed(by: bag)
        
        output.selectedUsers
            .asObservable()
            .map { (users) -> Int in
                return users.count
            }
            .subscribe { [weak self] (selectedUsersCount) in
                guard let `self` = self else { return }
                self.updateNextButtonState(enabled: selectedUsersCount.element != 0)
                self.collectionView.isHidden = selectedUsersCount.element == 0
            }.disposed(by: bag)
    
        output.loading
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)
    }
}
