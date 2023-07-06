//
//  CategorgyCollectionViewCell.swift
//  AiChat
//
//  Created by iApp on 13/06/23.
//

import UIKit


protocol CollectionViewCellDelegate: AnyObject {
    func moveToTemplate(objAITemplatesViewModel:AITemplatesViewModel)
    func showImageNdLable()
    func hideImageNdLable()
}


class CategorgyCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var categoryListCollectionView: UICollectionView!
    static let identifier = "CategorgyCollectionViewCell"
    var templateCategoryModel: TemplateCategoryModel?
    weak var delegate: CollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
    }

    func registerCell() {
        categoryListCollectionView.registerCell(identifire: Identifires.aiChatBuddyCollectionCell)
    }
        
    func shuffledByName(){
        if let sortedTemplates = templateCategoryModel?.templates?.sorted(by: { $0.name! < $1.name! }) {
            templateCategoryModel?.templates = sortedTemplates
        }
//        templateCategoryModel?.templates?.shuffle()
        categoryListCollectionView.reloadData()
    }
    func configureCell(with templateCategoryModel: TemplateCategoryModel){
        self.templateCategoryModel = templateCategoryModel
        shuffledByName()
    }
    func selectedCell(indexPath:IndexPath){
    
    }
    
}

//MARK: - CollectionView Delegate and Datasource
extension CategorgyCollectionViewCell: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if templateCategoryModel?.templates?.count == 0{
            delegate?.showImageNdLable()
        }else{
            delegate?.hideImageNdLable()
        }
        return templateCategoryModel?.templates?.count ?? 0

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: Identifires.aiChatBuddyCollectionCell, for: indexPath) as! AiChatBuddyCollectionViewCell
        
        if let templateModel = templateCategoryModel?.templates?[indexPath.row]{
            cellB.configureCellWithSearch(with: AITemplatesViewModel(chatTemplateData: templateModel))
            cellB.openSubscription = { _ in
//                self.openSubscription()
            }
        }
        return cellB
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
             let padding: CGFloat = 11
            debugPrint("Collection Width===" , collectionView.frame.size.width)
            if Device.IsIphone {
                let width = (collectionView.frame.size.width - padding)/2
                debugPrint("width after===", width)
                return CGSize(width: width, height: width)
            } else {
                let width = (collectionView.frame.size.width - padding)/3
                debugPrint("width after===", width)
                return CGSize(width: width, height: width - 55)
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        delegate?.moveToTemplate(selectedIndexPath: indexPath.row)
        
        if let template = templateCategoryModel?.templates?[indexPath.row]{
            delegate?.moveToTemplate(objAITemplatesViewModel: AITemplatesViewModel(chatTemplateData: template))
        }
            
//
//        if let template = templateCategoryModel?.templates?[indexPath.row]{
//            let controller = AiTemplatesChatSuggestionViewController.instantiate(fromAppStoryboard: .AITemplates)
//        controller.templatesVM = AITemplatesViewModel(chatTemplateData: template)
//            self.navigationController?.pushViewController(controller, animated:true)
        
           
        
        
        
        //Firebase event
//        fatalError("Firebase Crash")
//        To show IAP screen remove return true from iAPmanager isallpurchased
//       EventConstant.shared.eventForSelectedTemplate(TemplateName: templateVM.searchTeamplateArr[indexPath.item].name ?? "")
//        let templateModel = templateCategoryModel?.templates?[indexPath.row]
////        if templateModel?.isPro == false || IAPManager.shared.isPurchased{
//        let controller = AiTemplatesViewController.instantiate(fromAppStoryboard: <#T##AppStoryboard#>)   //instantiate(fromAppStoryboard: .Main)
////            controller.templatesVM = AITemplatesViewModel(chatTemplateData: templateModel)
//            self.navigationController?.pushViewController(controller, animated:true)
//        } else {
//            if !IAPManager.shared.isPurchased {
//                self.openSubscription()
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if Device.IsIpad {
            return 5
        } else {
            return 11
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 0 ,bottom: 10, right: 0)
        }
}
