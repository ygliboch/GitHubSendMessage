//
//  SelectedUserCell.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 10.05.2021.
//

import UIKit
import RxSwift

class SelectedUserCell: UICollectionViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    //MARK: - Properties
    
    private var bag = DisposeBag()
    
    //MARK: - Cell life cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userPhoto.sd_cancelCurrentImageLoad()
        userPhoto.image = nil
        bag = DisposeBag()
    }
    
    //MARK: - Bind ui
    
    func configure(with user: User) {
        username.text = user.login ?? ""
        userPhoto.sd_setImage(with: URL(string: user.avatar_url ?? ""), completed: nil)
    }
    
    //MARK: - Bind rx
    
    func bindViewModel<O>(row: Int, deleteButtonClicked: O) where O: ObserverType, O.Element == Int {
        removeButton.rx
            .controlEvent(.touchUpInside)
            .map { _ in row }
            .bind(to: deleteButtonClicked)
            .disposed(by: bag)
    }
}
