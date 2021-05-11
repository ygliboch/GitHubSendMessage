//
//  SelectUserViewModel.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 09.05.2021.
//

import Foundation
import RxSwift
import RxCocoa

class SelectUserViewModel: ViewModelType {
 
    //MARK: - Properties
    
    struct Input {
        let trigger: Driver<Void>
        let selectedTrigger: Driver<Int>
        let removeSelectedTrigger: Observable<Int>
        let paginationTrigger: Observable<CGPoint>
        let nextButtonClicked: Driver<Void>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let users: BehaviorRelay<[User]>
        let selectedUsers: BehaviorRelay<[User]>
    }
    
    struct Dependencies {
        let api: GitHubApiProvider
        let navigator: SelectUserNavigator
    }
    
    private let dependencies: Dependencies
    private var lastUserId: Int = 0
    let users = BehaviorRelay<[User]>(value: [])
    let selectedUsers = BehaviorRelay<[User]>(value: [])
    private let bag = DisposeBag()
    
    //MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
 
    //MARK: - Bind rx
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let loading = activityIndicator.asDriver()
        
        input.trigger
            .asObservable()
            .flatMap ({ _ -> Observable<[User]> in
                self.lastUserId = 0
                return self.dependencies.api.getUsers(since: self.lastUserId)
                    .trackActivity(activityIndicator)
            })
            .subscribe { [weak self] (users) in
                guard let `self` = self else { return }
                self.lastUserId = users.element?.last?.id ?? 0
                self.users.accept(self.markIfSelected(users: users.element ?? []))
            }.disposed(by: bag)
        
        input.paginationTrigger
            .asObservable()
            .distinctUntilChanged()
            .flatMapFirst { _ -> Observable<[User]> in
                self.dependencies.api.getUsers(since: self.lastUserId)
                    .trackActivity(activityIndicator)
            }
            .subscribe { [weak self] (users) in
                guard let `self` = self else { return }
                self.lastUserId = users.element?.last?.id ?? 0
                self.users.accept(self.users.value + (self.markIfSelected(users: users.element ?? [])))
            }.disposed(by: bag)
        
        input.selectedTrigger
            .asObservable()
            .map { id -> User in
                let user = self.users.value[id]
                return user
            }
            .subscribe { [weak self ](user) in
                guard let `self` = self else { return }
                if self.selectedUsers.value.contains(user.element ?? User()) {
                    let index = self.selectedUsers.value.lastIndex {$0.id == user.element?.id} ?? 0
                    var selectedUsersValue = self.selectedUsers.value
                    selectedUsersValue.remove(at: index)
                    self.selectedUsers.accept(selectedUsersValue)
                } else {
                    self.selectedUsers.accept(self.selectedUsers.value + [user.element ?? User()])
                }
                
                self.users.accept(self.markIfSelected(users: self.users.value))
            }.disposed(by: bag)
        
        
        input.removeSelectedTrigger
            .asObservable()
            .map { id -> User in
                let user = self.selectedUsers.value[id]
                return user
            }
            .subscribe { [weak self] (user) in
                guard let `self` = self else { return }
                let index = self.selectedUsers.value.lastIndex {$0.id == user.element?.id} ?? 0
                var selectedUsersValue = self.selectedUsers.value
                selectedUsersValue.remove(at: index)
                self.selectedUsers.accept(selectedUsersValue)
                self.users.accept(self.markIfSelected(users: self.users.value))
            }.disposed(by: bag)
        
        input.nextButtonClicked
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dependencies.navigator.toComposeMessage(selectedUsers: self.selectedUsers)
            })
            .disposed(by: bag)
            
        
        return Output(loading: loading, users: users, selectedUsers: selectedUsers)
    }
    
    private func markIfSelected(users: [User]) -> [User] {
        var markedUsers: [User] = []
        for user in users {
            var markedUser = user
            markedUser.isSelected = selectedUsers.value.contains(user)
            markedUsers.append(markedUser)
        }
        return markedUsers
    }
}
