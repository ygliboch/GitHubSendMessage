//
//  UIStoryboardExtension.swift
//  GitHubMessage
//
//  Created by Yaroslava Hlibochko on 09.05.2021.
//

import Foundation
import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {
    var selectUserController: SelectUserController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "SelectUserController") as? SelectUserController else {
            fatalError("SelectUserController couldn't be found in Storyboard file")
        }
        return vc
    }
    
    var composeMessageController: ComposeMessageController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "ComposeMessageController") as? ComposeMessageController else {
            fatalError("SelectUserController couldn't be found in Storyboard file")
        }
        return vc
    }
}
