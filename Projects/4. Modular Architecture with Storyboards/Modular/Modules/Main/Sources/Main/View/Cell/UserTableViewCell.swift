//
//  UserTableViewCell.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import UIKit
import Models

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with data: UserViewData) {
        nameLabel.text = data.name
        usernameLabel.text = data.username
        emailLabel.text = data.email
        cityLabel.text = data.address
        companyLabel.text = data.company
    }
}
