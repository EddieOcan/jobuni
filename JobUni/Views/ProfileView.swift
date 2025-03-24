import SwiftUI
import UIKit
import Firebase
import FirebaseStorage

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var photoURL: URL?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isUploadingImage = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var creationDate: Date?
    @State private var showingWebsiteAlert = false
    @State private var websiteURL = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Foto profilo
                ZStack(alignment: .bottomTrailing) {
                    if let photoURL = photoURL {
                        AsyncImage(url: photoURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 7)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 7)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                
                if isUploadingImage {
                    ProgressView("Caricamento in corso...")
                        .padding()
                }
                
                // Info utente
                VStack(spacing: 20) {
                    ProfileInfoCard(title: "Nome", value: username, icon: "person.fill")
                    ProfileInfoCard(title: "Email", value: email, icon: "envelope.fill")
                    
                    if let creationDate = creationDate {
                        ProfileInfoCard(
                            title: "Membro dal",
                            value: formattedDate(creationDate),
                            icon: "calendar"
                        )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Impostazioni sito web
                VStack(alignment: .leading, spacing: 15) {
                    Text("Sito Web Curriculum")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // In una implementazione reale, questo genererebbe il sito web
                        websiteURL = "https://jobuni.web.app/cv/\(authViewModel.user?.uid ?? "")"
                        showingWebsiteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Genera Sito Web")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    if !websiteURL.isEmpty {
                        VStack(alignment: .leading) {
                            Text("URL del tuo CV:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text(websiteURL)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Button(action: {
                                    UIPasteboard.general.string = websiteURL
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                // Pulsanti azioni account
                VStack(spacing: 10) {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Disconnetti")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showingDeleteAccountAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Elimina Account")
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Info app
                VStack(alignment: .center, spacing: 5) {
                    Text("JobUni")
                        .font(.headline)
                    
                    Text("Versione 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle("Profilo")
        .onAppear(perform: loadUserData)
        .sheet(isPresented: $showingImagePicker, onDismiss: uploadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert("Disconnessione", isPresented: $showingLogoutAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Disconnetti", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Sei sicuro di voler uscire?")
        }
        .alert("Elimina Account", isPresented: $showingDeleteAccountAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                // Qui implementeremmo la cancellazione dell'account
                // In una app reale questo richiederebbe altre verifiche
            }
        } message: {
            Text("Tutti i tuoi dati verranno eliminati definitivamente. Questa azione è irreversibile.")
        }
        .alert("Sito Web Generato", isPresented: $showingWebsiteAlert) {
            Button("OK", role: .cancel) { }
            Button("Copia Link") {
                UIPasteboard.general.string = websiteURL
            }
        } message: {
            Text("Il tuo CV è ora disponibile online! Puoi condividere questo link con i tuoi contatti professionali.")
        }
    }
    
    private func loadUserData() {
        guard let user = authViewModel.user else { return }
        
        email = user.email ?? ""
        
        if let photoURLString = user.photoURL?.absoluteString {
            photoURL = URL(string: photoURLString)
        }
        
        // Carica il nome utente da Firestore
        Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
            if let error = error {
                print("Errore nel caricamento del profilo: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                self.username = data["name"] as? String ?? ""
                
                if let timestamp = data["createdAt"] as? Timestamp {
                    self.creationDate = timestamp.dateValue()
                }
            }
        }
    }
    
    private func uploadImage() {
        guard let inputImage = inputImage else { return }
        guard let user = authViewModel.user else { return }
        guard let imageData = inputImage.jpegData(compressionQuality: 0.8) else { return }
        
        isUploadingImage = true
        
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Errore nel caricamento dell'immagine: \(error.localizedDescription)")
                isUploadingImage = false
                return
            }
            
            storageRef.downloadURL { url, error in
                isUploadingImage = false
                
                if let error = error {
                    print("Errore nell'ottenimento dell'URL: \(error.localizedDescription)")
                    return
                }
                
                guard let url = url else { return }
                
                self.photoURL = url
                
                // Aggiorna l'URL nel profilo utente
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = url
                
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Errore nell'aggiornamento del profilo: \(error.localizedDescription)")
                    }
                }
                
                // Aggiorna anche nel database Firestore
                Firestore.firestore().collection("users").document(user.uid).updateData([
                    "photoURL": url.absoluteString
                ]) { error in
                    if let error = error {
                        print("Errore nell'aggiornamento del database: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
}

struct ProfileInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Non fa nulla
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthViewModel())
        }
    }
} 