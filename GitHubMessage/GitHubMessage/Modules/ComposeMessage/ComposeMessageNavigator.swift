//
//  ComposeMessageNavigator.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 11.05.2021.
//

import UIKit

protocol ComposeMessageNavigatable {
    func toBack()
}

final class ComposeMessageNavigator: ComposeMessageNavigatable {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toBack() {
        navigationController.popViewController(animated: true)
    }
}
