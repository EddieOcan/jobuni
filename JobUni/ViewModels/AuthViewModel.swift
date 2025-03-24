import Foundation
import Firebase
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Ascolta i cambiamenti nello stato di autenticazione
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            self.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            // Autenticazione riuscita
            self.errorMessage = ""
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else {
                self.errorMessage = "Si è verificato un errore durante la registrazione"
                return
            }
            
            // Crea il profilo utente nel database
            let userData = [
                "name": name,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                // Registrazione completata con successo
                self.errorMessage = ""
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 