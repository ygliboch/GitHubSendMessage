//
//  UserCell.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 10.05.2021.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var mark: UIImageView!
    
    //MARK: - Cell life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userPhoto.sd_cancelCurrentImageLoad()
        userPhoto.image = nil
    }
    
    //MARK: - Bind ui
    
    func configure(with user: User) {
        username.text = user.login ?? ""
        link.text = user.url ?? ""
        userPhoto.sd_setImage(with: URL(string: user.avatar_url ?? ""), completed: nil)
        mark.image = (user.isSelected ?? false) ? #imageLiteral(resourceName: "_ionicons_svg_ios-checkmark-circle") : #imageLiteral(resourceName: "_ionicons_svg_ios-radio-button-off")
    }

}
