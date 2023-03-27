//
//  SearchViewControllerCell.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/14.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton)
    }


class SearchTableViewCell: UITableViewCell {
    
    var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var followingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func follow(button: UIButton) {
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }
    
}
