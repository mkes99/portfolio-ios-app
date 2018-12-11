//
//  FilterCollectionViewCell.swift
//  portfolio
//
//  Created by Formative Mini on 11/12/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit

protocol FilterCollectionViewCellDelegate {
    func filterPost(selectedTagIds: [String])
}

class FilterCollectionViewCell: UICollectionViewCell {
    
    var filteredButtons = [CustomButton]()
    var filterButton: CustomButton!
    var filterButtonXCoord: CGFloat = 5.0
    
    var delegate: FilterCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        filterButton = CustomButton(type: .custom)
        filterButton.layer.borderColor = UIColor.white.cgColor
        filterButton.layer.borderWidth = 2.0
        filterButton.frame.size.height = 34.0
        filterButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        filterButton.layer.cornerRadius =  filterButton.frame.height / 2
        contentView.addSubview(filterButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame =  filterButton.frame
        frame.size.height = 34.0
        frame.size.width = self.frame.size.width
        frame.origin.x = 0
        frame.origin.y = 0
        filterButton.frame = frame
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var filterTag: TagModel? {
        didSet {
            updateView()
        }
    }

    func updateView() {

        guard let title = filterTag?.title, let value = filterTag?.value else {
            return
        }

        filterButton.value = value
        filterButton.titleLabel?.text = title
        filterButton.setTitle(title, for: .normal)
        filterButton.isSelected = false
        filterButton.sizeToFit()
//        filterButton.frame = CGRect(x: filterButtonXCoord, y: CGFloat(5.0), width: filterButton.frame.size.width, height: CGFloat(34.0))
//        self.frame.size.width = filterButton.frame.width

//        print("test", filterButton.frame.width)
//
//        filterButton.frame.size = CGSize(width: filterButton.frame.width, height: 34.0)

        self.frame.size.width = filterButton.frame.width

        filteredButtons.append(filterButton)
        filterButton.addTarget(self, action: #selector(self.filtersButtonTapped), for: .touchUpInside)
        filterButtonXCoord += filterButton.frame.width + 10

    }
    
    @objc func filtersButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
        } else {
            sender.backgroundColor = .clear
            sender.setTitleColor(.white, for: .normal)
        }
      
        let selectedTagIds = getSelectedButtons()
        
        delegate?.filterPost(selectedTagIds: selectedTagIds )
    }
    
    func getSelectedButtons() -> [String] {
        return filteredButtons.filter({ $0.isSelected }).compactMap({ $0.value })
    }
}



