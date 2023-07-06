//
//  AiTemplatesViewController.swift
//  AiChat
//
//  Created by iApp on 17/04/23.
//

import UIKit
import StoreKit

protocol CustomCellDelegate: AnyObject {
    func removeImageViewFromCells()
}


class AiTemplatesViewController: ParentViewController {
    
    class func control() -> AiTemplatesViewController {
        let control = self.control(.Main) as? AiTemplatesViewController
        return control ?? AiTemplatesViewController()
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var crossTextFieldButton: UIButton!
    @IBOutlet weak var searchLabelPlaceholder: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBgView: UIView!
    @IBOutlet weak var AiAssistantCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var notFoundDescriptionLabel: UILabel!
    @IBOutlet weak var resultNotFoundLabel: UILabel!
    @IBOutlet weak var notFoundImageView: UIImageView!
    //MARK: - Variables Declared
    var selectedIndex: Int? = 0
    weak var delegate: CustomCellDelegate?

    var controller : UIViewController? = nil
    var completionHandler:((ChatGPT)->())?
    var filterData:[String]!
    var templateVM = ChooseTemplateViewModel()
    var selectedTemplateForIAP: Int?
    var templateCategoryModel: TemplateCategoryModel?
    var isTextFieldEditing = false
    var selectedItemIndex: Int = 0


    override func loadView() {
        super.loadView()
        if !Preferences.doneWelcomeScreenFlow {
            let controller = WelcomeViewController.instantiate(fromAppStoryboard: .Welcome)
            controller.modalPresentationStyle = .fullScreen
            controller.delegate = self
            self.present(controller, animated: false)
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
       
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
   
    
    //MARK: - SetupUI Method
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        crossTextFieldButton.isHidden = true
        AiAssistantCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        notFoundImageView.isHidden = true
        notFoundDescriptionLabel.isHidden = true
        resultNotFoundLabel.isHidden = true
        self.registerCell()
        AiAssistantCollectionView.keyboardDismissMode = .onDrag
        Helper.dispatchDelay(deadLine: .now() + 0.8) {
            self.searchTextField.setDoneOnKeyboardtextfield(textfield: self.searchTextField)
        }
        
        templateVM.loadVideosFromJSONFiles {
            Helper.dispatchMain {
                self.AiAssistantCollectionView.reloadData()
                self.categoryCollectionView.reloadData()
            }
        }
        searchBgView.layer.cornerRadius = 8
        searchBgView.addShadow()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        searchTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(openSubscriptionIfProductFound), name: Notification.Name.productFound, object: nil)
        if let sortedTemplates = templateCategoryModel?.templates?.sorted(by: { $0.name! > $1.name! }) {
         
            for template in sortedTemplates {
                
                debugPrint(template.name!)
            }
        }
        templateCategoryModel?.templates?.shuffle()

    }
   
  

    //MARK: - In App screen open
    @objc func openSubscriptionIfProductFound() {
        if Preferences.firstAppSessionDone && !IAPManager.shared.isPurchased {
            self.openSubscriptionScreen()
        }
    }
    
    func openSubscriptionScreen() {
        if !Reachability.shared.isConnectedToNetwork{
            UIAlertController.showAlert(title: "Network Lost!", message: ErrorMessage.error_Internet_connectMessage, actions: ["Ok":.default])
            return
        } else {
            let controller = AISubscriptionViewController.instantiate(fromAppStoryboard: .Purchase)
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
    //MARK: - Register Cell
    func registerCell() {
        AiAssistantCollectionView.registerCell(identifire: CategorgyCollectionViewCell.identifier)
        categoryCollectionView.registerCell(identifire: CategoryCollectionIndetifier.indentifierOfCategory) // iqbal
        
    }
    
    func hideShowPlaceholderLabel() {
        if searchTextField.text == "" {
            self.searchLabelPlaceholder.isHidden = false
            self.crossTextFieldButton.isHidden = true
        } else {
            self.searchLabelPlaceholder.isHidden = true
            self.crossTextFieldButton.isHidden = false
        }
    }
    
    // MARK: PRESENT SUBSCRIPTION CONTROLER
    
    func openSubscription() {
        if !Reachability.shared.isConnectedToNetwork{
            UIAlertController.showAlert(title: "Network Lost!", message: ErrorMessage.error_Internet_connectMessage, actions: ["Ok":.default])
            return
        } else{
            let controller = AISubscriptionViewController.instantiate(fromAppStoryboard: .Purchase)
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
   
    
    @IBAction func chatHistoryButtonClicked(_ sender: UIButton) {
        let controller = ChatHistoryViewController.instantiate(fromAppStoryboard: .Main)
        controller.isFromHome = true
        self.navigationController?.pushViewController(controller, animated:true)
    }
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        let controller = SettingViewController.instantiate(fromAppStoryboard: .Setting)
        self.navigationController?.pushViewController(controller, animated:true)
    }
    
    @IBAction func clearTextFiedButton(_ sender: Any) {
        searchTextField.text = ""
        self.templateVM.refreshAllSearchData()
        self.AiAssistantCollectionView.reloadData()
        searchLabelPlaceholder.isHidden = false
        if searchTextField.text == "" {
            crossTextFieldButton.isHidden = true
        } else {
            crossTextFieldButton.isHidden = false
        }
        searchTextField.resignFirstResponder()
    }
}

//MARK: - CollectionView Delegate and Datasource
extension AiTemplatesViewController: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,CollectionViewCellDelegate {
    func showImageNdLable() {
        notFoundImageView.isHidden = false
        notFoundDescriptionLabel.isHidden = false
        resultNotFoundLabel.isHidden = false
    }
    
    func hideImageNdLable() {
        notFoundImageView.isHidden = true
        notFoundDescriptionLabel.isHidden = true
        resultNotFoundLabel.isHidden = true
    }
    
    func moveToTemplate(objAITemplatesViewModel: AITemplatesViewModel) {
            let controller = AiTemplatesChatSuggestionViewController.instantiate(fromAppStoryboard: .AITemplates)
            controller.templatesVM = objAITemplatesViewModel
            self.navigationController?.pushViewController(controller, animated:true)
    }
    
//    func moveToTemplate(selectedIndexPath: Int) {
//        if let template = templateCategoryModel?.templates?[selectedIndexPath]{
//            let controller = AiTemplatesChatSuggestionViewController.instantiate(fromAppStoryboard: .Main)
//            controller.templatesVM = AITemplatesViewModel(chatTemplateData: template)
//            self.navigationController?.pushViewController(controller, animated:true)
//        }
//    }
//
   
        
        // find category Object with name of category
        // get template with form list of templaets with index
        // navigate to next screen with template
        
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateVM.numberOfCategories
        
            /*   if templateVM.searchTeamplateArr.count == 0 {
             notFoundImageView.isHidden = false
             notFoundDescriptionLabel.isHidden = false
             resultNotFoundLabel.isHidden = false
             } else {
             notFoundImageView.isHidden = true
             notFoundDescriptionLabel.isHidden = true
             resultNotFoundLabel.isHidden = true
             }*/
            
        
//               return templateVM.searchTeamplateArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryCollectionView {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionIndetifier.indentifierOfCategory, for: indexPath) as! CategorgyTitleCollectionCell
            
            let categoryName = templateVM.categoryNameAt(index: indexPath.item)
            let categoryIcon = templateVM.categoryIconAT(index: indexPath.item)
            cellA.catgryName.text = categoryName
            cellA.catgryIcon.image = UIImage(named: categoryIcon)
            cellA.layer.cornerRadius = 8.0
            cellA.updateCellData(index: indexPath.row)
                if indexPath.item == self.selectedIndex {
                    cellA.indicatorImageView.backgroundColor = UIColor.white
                  } else {
                      cellA.indicatorImageView.backgroundColor = UIColor.clear
                      
                  }
            
            return cellA
        } else {
            let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: CategorgyCollectionViewCell.identifier, for: indexPath) as! CategorgyCollectionViewCell
            cellB.delegate = self
           if let templateCategory = templateVM.categoryAtIndex(index: indexPath.item){
                cellB.configureCell(with: templateCategory)
            }
            
            /*   self.selectedTemplateForIAP = indexPath.item
             let templateModel = templateVM.searchTeamplateArr[indexPath.row]
             cellB.configureCellWithSearch(with: AITemplatesViewModel(chatTemplateData: templateModel))
             cellB.openSubscription = { _ in
             self.openSubscription()
             }*/
            return cellB
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let categoryName = templateVM.categoryNameAt(index: indexPath.item)
        if collectionView == self.categoryCollectionView {
            let width = categoryName.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)]).width + 60
            //            let height = collectionView.frame.size.height
            debugPrint("width after===", width)
            return CGSize(width: width, height: 42.0)
        }else{
            return collectionView.bounds.size
        }
        /*  let padding: CGFloat = 11
         debugPrint("Collection Width===" , collectionView.frame.size.width)
         if Device.IsIphone {
         let width = (collectionView.frame.size.width - padding)/2
         debugPrint("width after===", width)
         return CGSize(width: width, height: width)
         } else {
         let width = (collectionView.frame.size.width - padding)/3
         debugPrint("width after===", width)
         return CGSize(width: width, height: width - 55)
         }*/
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndex = selectedIndex {
                let previousSelectedIndexPath = IndexPath(item: selectedIndex, section: 0)
                self.selectedIndex = nil
                collectionView.reloadItems(at: [previousSelectedIndexPath])
            }
            // Update the selectedIndex variable
            selectedIndex = indexPath.item
            
            // Reload the newly selected cell
            collectionView.reloadItems(at: [indexPath])
            
            // Scroll to the selected cell
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
    
        if collectionView == self.categoryCollectionView {
            if indexPath.row == selectedItemIndex{
//                searchTextField.becomeFirstResponder()
            }else{
                searchTextField.resignFirstResponder()
            }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.AiAssistantCollectionView.reloadItems(at: [indexPath])
            AiAssistantCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        
        /*    EventConstant.shared.eventForSelectedTemplate(TemplateName: templateVM.searchTeamplateArr[indexPath.item].name ?? "")
         let templateModel = self.templateVM.searchTeamplateArr[indexPath.row]
         if templateModel.isPro == false || IAPManager.shared.isPurchased{
         let controller = AiTemplatesChatSuggestionViewController.instantiate(fromAppStoryboard: .AITemplates)
         controller.templatesVM = AITemplatesViewModel(chatTemplateData: templateModel)
         self.navigationController?.pushViewController(controller, animated:true)
         } else {
         if !IAPManager.shared.isPurchased {
         self.openSubscription()
         }
         }*/
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if Device.IsIpad {
            return 0
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.categoryCollectionView {
            return UIEdgeInsets(top: 0, left: 5.0, bottom: 16, right: 16)
        }else{
            return UIEdgeInsets(top: 5, left: 0 ,bottom: 30, right: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

//MARK: - TextField Delegates 
extension AiTemplatesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTextFieldEditing = true
        
        self.searchLabelPlaceholder.isHidden = true
        self.collectionView(self.categoryCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isTextFieldEditing = false
        self.hideShowPlaceholderLabel()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let deleteTapped = string == ""
        let cursorAtBeginning = range.location == 0
        let deletedCharactersEqualtoTextfieldcount = range.length == textField.text?.count
        
        let everythingWasDeleted = deleteTapped && cursorAtBeginning && deletedCharactersEqualtoTextfieldcount
        if everythingWasDeleted {
            self.searchLabelPlaceholder.isHidden = false
            crossTextFieldButton.isHidden = true
        } else {
            self.searchLabelPlaceholder.isHidden = true
            crossTextFieldButton.isHidden = false
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text!.count > 0 {
            self.templateVM.searchText(text: textField.text)
        } else {
            self.templateVM.refreshAllSearchData()
        }
        self.AiAssistantCollectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x > 0 {
//            searchTextField.resignFirstResponder()
//            searchTextField.text = ""
//        }
//    }
}

extension AiTemplatesViewController: DidUpdateIAPScreen {
    func presentIAPScreen() {
        self.openSubscriptionScreen()
    }
}
