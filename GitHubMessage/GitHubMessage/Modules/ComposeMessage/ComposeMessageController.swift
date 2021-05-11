//
//  ComposeMessageController.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 11.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

class ComposeMessageController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    
    //MARK: - Properties

    var viewModel: ComposeMessageViewModel!
    private let bag = DisposeBag()
    private let backButton = UIButton()
    private var tabGesture = UITapGestureRecognizer()
    
    //MARK: - Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        addBackgroundGesture()
        bindViewModel()
    }
    
    //MARK: - Bind ui
    
    private func configureNavigationBar() {
        navigationItem.title = "Compose Message"
        
        backButton.setTitle("< Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func addBackgroundGesture() {
        view.addGestureRecognizer(tabGesture)
    }
    
    //MARK: - Bind rx
    
    private func bindViewModel() {
        let removeFromSelectedButtonClicked = PublishSubject<Int>()
        let sendTrigger = sendButton.rx.controlEvent(.touchUpInside)
            .asDriver()
        let backTrigger = backButton.rx.controlEvent(.touchUpInside)
            .asDriver()
        
        let input = ComposeMessageViewModel.Input(removeSelectedTrigger: removeFromSelectedButtonClicked,
                                                  sendTrigger: sendTrigger,
                                                  backTrigger: backTrigger)
        
        let output = viewModel.transform(input: input)
        
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
                self.collectionView.isHidden = selectedUsersCount.element == 0
            }.disposed(by: bag)
        
        let isSelectedUsersNotEmpty = output.selectedUsers.asObservable()
            .map { (users) -> Bool in
                !users.isEmpty
            }
        
        let isMessageNotEmpty = textView.rx.didChange
            .asObservable()
            .map { (_) -> Bool in
                !self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        
        Observable.combineLatest(isSelectedUsersNotEmpty, isMessageNotEmpty)
            .map { (isSelectedUsersNotEmpty, isMessageNotEmpty) -> Bool in
                return isSelectedUsersNotEmpty && isMessageNotEmpty
            }
            .subscribe { [weak self] isSendEnabled in
                guard let `self` = self else { return }
                self.sendButton.setTitleColor((isSendEnabled.element ?? false) ? .black : .systemGray5, for: .normal)
                self.sendButton.isUserInteractionEnabled = (isSendEnabled.element ?? false)
            }
            .disposed(by: bag)
        
        tabGesture.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: bag)
    }

}
