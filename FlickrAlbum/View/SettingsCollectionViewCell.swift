//
//  SettingsCollectionViewCell.swift
//  FlickrAlbum
//
//  Created by Vineet Singh on 23/07/18.
//  Copyright © 2018 Vineet Singh. All rights reserved.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    
    override var isHighlighted: Bool{
        didSet{
            backgroundColor = isHighlighted ?  UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0) : UIColor.white
            rowLabel.textColor = isHighlighted ? UIColor.white : UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        }
    }
    
    
    
    
    let rowLabel: UILabel = {
       
        let label = UILabel()
        label.text = "Images Per Row: 1"
        label.textColor = UIColor(red: 1.0, green: 51/255, blue: 101/255, alpha: 1.0)
        label.font = UIFont(name: "GothamRounded-Medium", size: 13)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        addSubview(rowLabel)
        
        addConstraintsWithFormat(format: "H:|-20-[v0]|", views: rowLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: rowLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
