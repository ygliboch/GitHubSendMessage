//
//  SelectUserNavigator.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 09.05.2021.
//

import UIKit
import RxSwift
import RxCocoa

protocol SelectUserNavigatable {
    func toComposeMessage(selectedUsers: BehaviorRelay<[User]>)
}

final class SelectUserNavigator: SelectUserNavigatable {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toComposeMessage(selectedUsers: BehaviorRelay<[User]>) {
        let vc = UIStoryboard.main.composeMessageController
        let navigator = ComposeMessageNavigator(navigationController: navigationController)
        let viewModel = ComposeMessageViewModel(dependencies: ComposeMessageViewModel.Dependencies(navigator: navigator, selectedUsers: selectedUsers))
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
