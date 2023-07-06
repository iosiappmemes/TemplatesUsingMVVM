//
//  AITemplatesViewModel.swift
//  AiChat
//
//  Created by iApp on 24/04/23.
//

import Foundation


class AITemplatesViewModel {
    private var chatTemplateData: ChatTemplatesModel
//    public var fieldsVM = [FieldsViewModel]()
    var shouldRemoveEmptyFields: Bool = false
    
    init(chatTemplateData: ChatTemplatesModel) {
        self.chatTemplateData = chatTemplateData
        
//        fieldsVM = chatTemplateData.fields?.compactMap({FieldsViewModel(fieldsData: $0)}) ?? []
    }
    
    var templateId: Int{
        return chatTemplateData.id!
    }
    
    var templateIdString: String{
        return String(chatTemplateData.id!)
    }
    var aiTemplateName: String{
        return chatTemplateData.name ?? ""
    }
    
    var imageName: String {
        return chatTemplateData.imageName ?? ""
    }
    
    var promptText: String {
        return chatTemplateData.promptText ?? ""
    }
    
    var aiTemplateImage: String {
        return chatTemplateData.icon ?? ""
    }
    
    var description: String {
        return chatTemplateData.description ?? ""
    }
    
    var isPro: Bool {
        return chatTemplateData.isPro ?? false
    }
    
    var fieldCount: Int {
        if shouldRemoveEmptyFields {
            let fillTextPrompt = chatTemplateData.fields?.filter({$0.inputText != "" && $0.inputText != nil})
            debugPrint("Section count fillTextPrompt?.count",fillTextPrompt?.count)
            return fillTextPrompt?.count ?? 1
        } else {
            debugPrint(" Section count chatTemplateData.fields?.coun",chatTemplateData.fields?.count)
            return chatTemplateData.fields?.count ?? 0
        }
    }
   

    func fieldAt(index: Int) -> Field? {
        return chatTemplateData.fields?[index]
    }
    
    func updateFieldText(text:String?, atIndex index: Int){
        chatTemplateData.fields?[index].inputText = text
    }
    
    var shouldEnableGenerateButton: Bool {
        if let inputtext = chatTemplateData.fields?.first?.inputText, inputtext != ""{
            return true
        }
        return false
    }
    
    var shouldEnableGenerateButtons: Bool {
        if let inputtext = chatTemplateData.fields?.first?.inputText, inputtext == ""{
            return true
        }
        return false
    }
}


class ChooseTemplateViewModel:NSObject {
    
    var allOriginalCategoryModel: TemplateCategoryModel?
    var templateCategoryModelArr: [TemplateCategoryModel] = []
    
    func loadVideosFromJSONFiles(_ completion: @escaping () -> Void) {
        let fileNames = ["AIMarketing", "AISocial", "AILanguageTranslator", "AISpellChecker", "AINews", "AIPressRelase", "AIConetentGenerator", "AIFitnes", "AIGenerateMusic", "AICodeGenerator", "AIGenerateCaption","AIFaq","AIGnerateCV","AIFood","AIBussiness","AISociaLMediaPlatform","AIHistory","AIHealth&Medicine","AIEducation","AIVacationPlanner","AISleepingTips","AITextToEmoji's","AIHoroscope","AIGenerateEssay","AIIdea's","AIWeather"]
        let dispatchGroup = DispatchGroup()
        
        var alltemplates = TemplateCategoryModel()
        alltemplates.categoryName = "All"
        
        for fileName in fileNames {
            dispatchGroup.enter()
            
            if let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "json") {
                
                if let data = try? Data(contentsOf: fileUrl) {
                    do {
                        let categoryData = try JSONDecoder().decode(TemplateCategoryModel.self, from: data)
                        templateCategoryModelArr.append(categoryData)
                        
                        if let templates = categoryData.templates, templates.count > 0 {
                            alltemplates.templates?.append(contentsOf: templates)
                        }
                        
                        debugPrint("templateCategoryModelArr ", templateCategoryModelArr)
                    } catch {
                        debugPrint(error)
                    }
                }
            }
            
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            var templates: [ChatTemplatesModel] = []
            for item in self.templateCategoryModelArr{
                templates.append(contentsOf: item.templates ?? [])
                alltemplates.templates = templates
    
            }
            self.allOriginalCategoryModel = alltemplates
            self.templateCategoryModelArr.insert(alltemplates, at: 0)
            completion()
        }
    }
    
    
    
    //MARK: - Get JSON data
    /*  private func getTemplatesFromJSON(_ completion:@escaping(()-> Void)) {
     if let fileUrl = Bundle.main.path(forResource: "AITemplatesChat", ofType: "json") {
     do {
     let data = try String(contentsOfFile: fileUrl).data(using: .utf8)
     self.arrChatBoatModel = try! JSONDecoder().decode([ChatTemplatesModel].self, from: data!)
     self.searchTeamplateArr = self.arrChatBoatModel
     
     
     //                let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [[String: Any]]
     //                self.arrTemplatesListModel = ChatTemplatesListModel(json: json ?? [])
     //                self.seletctedChatTemplateModel = self.arrTemplatesListModel.fieldsModel
     completion()
     print("File URL For Templates======" , fileUrl)
     } catch {
     print(error.localizedDescription)
     }
     }
     }
     */
    
    
    //MARK: - Search Text
    func searchText(text: String!)  {
        let filterdTemplates = self.allOriginalCategoryModel?.templates?.filter{
            $0.name?.lowercased().contains(text.lowercased()) == true
        }
        templateCategoryModelArr[0].templates = filterdTemplates
//        let filtered = templateCategoryModelArr.first?.templates?.filter {
//            $0.name?.lowercased().contains(text.lowercased()) == true
//        }
        
//      return filtered!
//        self.searchTeamplateArr =  filtered!
    }
    
    //MARK: - Refresh Search Data on cancel button click
    func refreshAllSearchData() {
//        self.searchTeamplateArr = self.arrChatBoatModel
        templateCategoryModelArr[0].templates = self.allOriginalCategoryModel?.templates
    }
    
    //MARK: - TemplateCategoryModel
    var numberOfCategories: Int{
        templateCategoryModelArr.count
    }
    
    
    func categoryNameAt(index: Int) -> String{
        return categoryAtIndex(index: index)?.categoryName ?? ""
    }
    
    func categoryIconAT(index: Int) -> String{
        return categoryAtIndex(index: index)?.categoryIcon ?? ""
        
    }
    func categoryAtIndex(index: Int) -> TemplateCategoryModel?{
        if numberOfCategories > index{
            return templateCategoryModelArr[index]
        }
        return nil
    }
    

}

