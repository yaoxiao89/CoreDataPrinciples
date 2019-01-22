//
//  ListItemCell.swift
//  CoreDataPrinciples
//
//  Copyright © 2019 Xiao Yao. All rights reserved.
//  See LICENSE.txt for licensing information.
//

import Foundation
import UIKit

class ListItemCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: ListItemCell.self)
    
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title2)
        contentView.addSubview(label)
        contentView.layoutMargins = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        let guide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            label.topAnchor.constraint(equalTo: guide.topAnchor),
            label.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }
    
}
