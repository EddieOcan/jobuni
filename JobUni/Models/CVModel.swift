import Foundation
import FirebaseFirestore

struct CVModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userID: String
    var personalInfo: PersonalInfo
    var education: [Education]
    var experience: [WorkExperience]
    var skills: [Skill]
    var languages: [Language]
    var createdAt: Date
    var updatedAt: Date
    
    var isComplete: Bool {
        !personalInfo.name.isEmpty &&
        !personalInfo.email.isEmpty &&
        !education.isEmpty &&
        !experience.isEmpty &&
        !skills.isEmpty
    }
}

struct PersonalInfo: Codable {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var location: String = ""
    var title: String = ""
    var summary: String = ""
    var photoURL: String = ""
}

struct Education: Identifiable, Codable {
    var id: String = UUID().uuidString
    var degree: String
    var institution: String
    var location: String
    var startDate: Date
    var endDate: Date?
    var isCurrentlyStudying: Bool = false
    var description: String = ""
    var color: String = "blue" // Per le card colorate
}

struct WorkExperience: Identifiable, Codable {
    var id: String = UUID().uuidString
    var position: String
    var company: String
    var location: String
    var startDate: Date
    var endDate: Date?
    var isCurrentlyWorking: Bool = false
    var description: String = ""
    var achievements: [String] = []
    var color: String = "green" // Per le card colorate
}

struct Skill: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var level: Int // 1-5
    var category: SkillCategory
}

enum SkillCategory: String, Codable, CaseIterable {
    case technical = "Tecnica"
    case soft = "Soft Skill"
    case language = "Lingua"
    case other = "Altro"
}

struct Language: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var proficiency: LanguageProficiency
}

enum LanguageProficiency: String, Codable, CaseIterable {
    case beginner = "Base"
    case intermediate = "Intermedio"
    case advanced = "Avanzato"
    case fluent = "Fluente"
    case native = "Madrelingua"
} 