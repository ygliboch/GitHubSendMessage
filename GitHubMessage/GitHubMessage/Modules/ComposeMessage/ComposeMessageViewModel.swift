//
//  ComposeMessageViewModel.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 11.05.2021.
//

import RxSwift
import RxCocoa

class ComposeMessageViewModel: ViewModelType {
    
    //MARK: - Properties
    
    struct Input {
        let removeSelectedTrigger: Observable<Int>
        let sendTrigger: Driver<Void>
        let backTrigger: Driver<Void>
    }
    
    struct Output {
        let selectedUsers: BehaviorRelay<[User]>
    }
    
    struct Dependencies {
        let navigator: ComposeMessageNavigator
        let selectedUsers: BehaviorRelay<[User]>
    }
    
    private let dependencies: Dependencies
    private let bag = DisposeBag()
    
    //MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
 
    //MARK: - Bind rx
    
    func transform(input: Input) -> Output {
        
        input.removeSelectedTrigger
            .asObservable()
            .map { id -> User in
                let user = self.dependencies.selectedUsers.value[id]
                return user
            }
            .subscribe {[weak self] (user) in
                guard let `self` = self else { return }
                
                let index = self.dependencies.selectedUsers.value.lastIndex {$0.id == user.element?.id} ?? 0
                var selectedUsersValue = self.dependencies.selectedUsers.value
                selectedUsersValue.remove(at: index)
                self.dependencies.selectedUsers.accept(selectedUsersValue)
            }.disposed(by: bag)
        
        input.backTrigger
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dependencies.navigator.toBack()
            })
            .disposed(by: bag)
        
        input.sendTrigger
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dependencies.selectedUsers.accept([])
                self.dependencies.navigator.toBack()
            })
            .disposed(by: bag)
        
        return Output(selectedUsers: self.dependencies.selectedUsers)
    }
    
}
