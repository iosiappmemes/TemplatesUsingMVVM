//
//  CategorgyTitleCollectionCell.swift
//  AiChat
//
//  Created by iApp on 12/06/23.
//

import UIKit

class CategorgyTitleCollectionCell: UICollectionViewCell {
    @IBOutlet weak var catgryIcon: UIImageView!
    @IBOutlet weak var catgryName: UILabel!
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var mainView: UIView!
    var selectedIndex:Int?
    override func awakeFromNib() {
        super.awakeFromNib()
           
    }
   
   
    func configureCellTopCategories(with categoryVM: TemplateCategoryModel){
        catgryName.text = categoryVM.categoryName
        catgryIcon.image = UIImage(named: categoryVM.categoryIcon!)

    }
    
    func updateCellData(index:Int){
        catgryName.textAlignment = .center
        mainView.backgroundColor = AppColors.cellAColor
        if index == 0 {
            let iconImageView = UIImageView(image: UIImage(named: "allIcon"))
            iconImageView.frame = CGRect(x: 15, y: (frame.height - 20) / 2, width: 20, height: 20)
          
            contentView.addSubview(iconImageView)
        } else {
            // Remove the icon from other cells
            for subview in contentView.subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
            }
        }
    }

    
}

