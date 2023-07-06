//
//  AITemplatesModel.swift
//  AiChat
//
//  Created by iApp on 24/04/23.
//

import Foundation
import UIKit


struct TemplateCategoryModel: Codable{
    var categoryName: String?
    var jsonFileName: String?
    var categoryIcon:String?
    var templates: [ChatTemplatesModel]?
//    var searchTeamplateArray : [ChatTemplatesModel]?
    
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "category"
        case categoryIcon = "categoryIcon"
        case jsonFileName = "fileName"
        case templates = "data"
//        case searchTeamplateArray = "searchTeamplateArray"
    }
    
    init(categoryName: String? = nil,categoryIcon:String? = nil,jsonFileName:String? = nil, templates: [ChatTemplatesModel]? = nil) {
        self.categoryName = categoryName
        self.templates = templates
        self.categoryIcon = categoryIcon
        self.jsonFileName = jsonFileName
//       / self.searchTeamplateArray = searchTeamplateArray
    }
    
}

struct ChatTemplatesModel: Codable {
    var name: String?
    var icon: String?
    var imageName : String?
    var description: String?
    var fields: [Field]?
    var promptText: String?
    var id: Int?
    var isPro: Bool

    enum CodingKeys: String, CodingKey {
        case name, icon, fields,description,imageName
        case promptText = "prompt_text"
        case id
        case isPro
    }
    
    init(dictionary: [String: Any]) {
        self.name =  dictionary["name"] as? String ?? ""
        self.icon = dictionary["icon"] as? String ?? ""
        self.imageName = dictionary["imageName"] as? String ?? ""
        self.fields = dictionary["fields"] as? [Field] ?? []
        self.promptText = dictionary["prompt_text"] as? String ?? ""
        self.id = dictionary["id"] as? Int ?? 0
        self.description = dictionary["description"] as? String ?? ""
        self.isPro = dictionary["isPro"] as? Bool ?? false
        
    }
}


// MARK: - Field
struct Field: Codable {
    var index: Int?
    var aiassistantName, placeholderText: String?
    var characterLimit: Int?
    var inputText : String?
    var shouldRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case index
        case aiassistantName = "aiassistant_name"
        case placeholderText = "placeholder_text"
        case characterLimit = "character_limit"
        case inputText
        case shouldRequired
    }
    
    init(dictionary: [String: Any]) {
        self.index =  dictionary["index"] as? Int ?? 0
        self.aiassistantName = dictionary["aiassistant_name"] as? String ?? ""
        self.placeholderText = dictionary["placeholder_text"] as? String ?? ""
        self.characterLimit = dictionary["prompt"] as? Int ?? 0
        self.inputText = dictionary["inputText"] as? String ?? ""
        self.shouldRequired = dictionary["shouldRequired"] as? Bool ?? false
        
    }
}

//["Marketing","Music","Fitness","News","spellChecker,LanguageTranslator","Social","PressRelease"]
