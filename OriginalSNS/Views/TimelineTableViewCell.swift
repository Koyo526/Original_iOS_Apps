//
//  TimelineTableViewCell.swift
//  OriginalSNS
//
//  Created by 村形皇映 on 2021/09/13.
//

import UIKit
import Cosmos

protocol TimelineTableViewCellDelegate {
   func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
  func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
  func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}


class TimelineTableViewCell: UITableViewCell {
   
    var delegate: TimelineTableViewCellDelegate?
    
    var passedNumber: Double = 0.0
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var timestampLabel: UILabel!
    
    @IBOutlet var cosmosView: CosmosView!
    
    @IBOutlet var cosmosLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        cosmosView.settings.fillMode = .half
        
        let ud = UserDefaults.standard
        passedNumber = Double(ud.integer(forKey: "Rating"))
        print(passedNumber)
        
        cosmosLabel.text = String(passedNumber)
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func like(button: UIButton) {
          self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
          
      }

      @IBAction func openMenu(button: UIButton) {
          self.delegate?.didTapMenuButton(tableViewCell: self, button: button)

      }
    
      @IBAction func showComments(button: UIButton) {
          self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
      }
      

}
