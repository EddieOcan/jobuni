import Foundation
import Firebase
import FirebaseFirestore
import Combine

class CVViewModel: ObservableObject {
    @Published var cv: CVModel?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentStep = 0
    @Published var isEditMode = false
    
    private var db = Firestore.firestore()
    private var userId: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(userId: String? = nil) {
        self.userId = userId
        
        // Crea un CV vuoto se non esiste
        if let userId = userId {
            loadCV(userId: userId)
        }
    }
    
    func loadCV(userId: String) {
        isLoading = true
        errorMessage = ""
        
        db.collection("cvs")
            .whereField("userID", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
                    return
                }
                
                if let document = snapshot?.documents.first {
                    do {
                        // Converte il documento Firestore in CVModel
                        var cv = try document.data(as: CVModel.self)
                        cv.id = document.documentID
                        self.cv = cv
                    } catch {
                        self.errorMessage = "Errore nella decodifica: \(error.localizedDescription)"
                    }
                } else {
                    // Crea un nuovo CV vuoto
                    self.createEmptyCV(userId: userId)
                }
            }
    }
    
    private func createEmptyCV(userId: String) {
        let emptyCV = CVModel(
            userID: userId,
            personalInfo: PersonalInfo(),
            education: [],
            experience: [],
            skills: [],
            languages: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Salva nel Firestore
        self.saveCV(cv: emptyCV) { [weak self] result in
            switch result {
            case .success(let id):
                var newCV = emptyCV
                newCV.id = id
                self?.cv = newCV
            case .failure(let error):
                self?.errorMessage = "Errore nella creazione: \(error.localizedDescription)"
            }
        }
    }
    
    func saveCV(cv: CVModel, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            if cv.id.isEmpty {
                // Nuova creazione
                let ref = try db.collection("cvs").addDocument(from: cv)
                completion(.success(ref.documentID))
            } else {
                // Aggiornamento
                try db.collection("cvs").document(cv.id).setData(from: cv)
                completion(.success(cv.id))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateCV() {
        guard var cv = self.cv else { return }
        
        cv.updatedAt = Date()
        
        isLoading = true
        errorMessage = ""
        
        saveCV(cv: cv) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success:
                self.cv = cv
            case .failure(let error):
                self.errorMessage = "Errore nel salvataggio: \(error.localizedDescription)"
            }
        }
    }
    
    // Gestione dei processi di raccolta dati step-by-step
    func moveToNextStep() {
        if currentStep < 5 { // Assumiamo 5 step: Info personali, Formazione, Esperienze, Competenze, Riepilogo
            currentStep += 1
        }
    }
    
    func moveToPreviousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    // Funzioni helper per aggiungere/modificare/rimuovere elementi
    func addEducation(_ education: Education) {
        guard var cv = self.cv else { return }
        cv.education.append(education)
        self.cv = cv
        updateCV()
    }
    
    func updateEducation(_ education: Education) {
        guard var cv = self.cv else { return }
        if let index = cv.education.firstIndex(where: { $0.id == education.id }) {
            cv.education[index] = education
            self.cv = cv
            updateCV()
        }
    }
    
    func removeEducation(at index: Int) {
        guard var cv = self.cv, cv.education.indices.contains(index) else { return }
        cv.education.remove(at: index)
        self.cv = cv
        updateCV()
    }
    
    func addExperience(_ experience: WorkExperience) {
        guard var cv = self.cv else { return }
        cv.experience.append(experience)
        self.cv = cv
        updateCV()
    }
    
    func updateExperience(_ experience: WorkExperience) {
        guard var cv = self.cv else { return }
        if let index = cv.experience.firstIndex(where: { $0.id == experience.id }) {
            cv.experience[index] = experience
            self.cv = cv
            updateCV()
        }
    }
    
    func removeExperience(at index: Int) {
        guard var cv = self.cv, cv.experience.indices.contains(index) else { return }
        cv.experience.remove(at: index)
        self.cv = cv
        updateCV()
    }
    
    func addSkill(_ skill: Skill) {
        guard var cv = self.cv else { return }
        cv.skills.append(skill)
        self.cv = cv
        updateCV()
    }
    
    func updateSkill(_ skill: Skill) {
        guard var cv = self.cv else { return }
        if let index = cv.skills.firstIndex(where: { $0.id == skill.id }) {
            cv.skills[index] = skill
            self.cv = cv
            updateCV()
        }
    }
    
    func removeSkill(at index: Int) {
        guard var cv = self.cv, cv.skills.indices.contains(index) else { return }
        cv.skills.remove(at: index)
        self.cv = cv
        updateCV()
    }
    
    func updatePersonalInfo(_ personalInfo: PersonalInfo) {
        guard var cv = self.cv else { return }
        cv.personalInfo = personalInfo
        self.cv = cv
        updateCV()
    }
} 