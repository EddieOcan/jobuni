import SwiftUI

struct AuthView: View {
    @State private var isSignIn = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // Sfondo
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)), Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo e intestazione
                VStack(spacing: 15) {
                    Text("JobUni")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(isSignIn ? "Bentornato!" : "Crea il tuo CV digitale")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                // Card di autenticazione
                VStack(spacing: 25) {
                    // Campi di input
                    VStack(spacing: 18) {
                        if !isSignIn {
                            AuthTextField(text: $name, placeholder: "Nome completo", icon: "person.fill")
                        }
                        
                        AuthTextField(text: $email, placeholder: "Email", icon: "envelope.fill")
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        AuthTextField(text: $password, placeholder: "Password", icon: "lock.fill", isSecure: true)
                    }
                    
                    // Messaggio di errore
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Pulsante principale
                    Button(action: handleAuthentication) {
                        Text(isSignIn ? "Accedi" : "Registrati")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 10)
                    
                    // Cambio modalità
                    Button(action: { withAnimation { isSignIn.toggle() } }) {
                        Text(isSignIn ? "Non hai un account? Registrati" : "Hai già un account? Accedi")
                            .foregroundColor(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                            .font(.subheadline)
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 35)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 25)
                
                Spacer()
            }
        }
    }
    
    private func handleAuthentication() {
        if isSignIn {
            authViewModel.signIn(email: email, password: password)
        } else {
            authViewModel.signUp(email: email, password: password, name: name)
        }
    }
}

struct AuthTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
                .padding(.leading, 8)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.vertical, 16)
                    .padding(.leading, 8)
            } else {
                TextField(placeholder, text: $text)
                    .padding(.vertical, 16)
                    .padding(.leading, 8)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel())
    }
} 