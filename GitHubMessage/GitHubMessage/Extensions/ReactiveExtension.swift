//
//  ReactiveExtension.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 10.05.2021.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}
