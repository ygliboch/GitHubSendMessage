//
//  ViewModelType.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 11.05.2021.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
