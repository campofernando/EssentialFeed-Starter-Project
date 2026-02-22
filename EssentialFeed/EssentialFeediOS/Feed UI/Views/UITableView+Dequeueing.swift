//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Fernando Campo Garcia on 09/11/25.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
