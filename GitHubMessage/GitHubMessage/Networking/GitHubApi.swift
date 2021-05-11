//
//  GitHubApi.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 09.05.2021.
//

import Foundation

import RxCocoa
import RxSwift

protocol GitHubApiProvider {
    func getUsers(since: Int) -> Observable<[User]>
}

class GitHubApi: GitHubApiProvider {
    
    func getUsers(since: Int) -> Observable<[User]> {
        return get(url: "https://api.github.com/users?per_page=30&since=\(since)").map { data -> [User] in
            guard data != nil, let response = try? JSONDecoder().decode([User].self, from: data!) else { return []}
            return response
        }
    }
    
    private func get(url: String) -> Observable<Data?> {
        guard let url = URL(string: url) else { return Observable.empty() }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return URLSession.shared.rx.data(request: request)
            .map { Optional.init($0) }
            .catchErrorJustReturn(nil)
    }
}
