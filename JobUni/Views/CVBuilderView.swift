import SwiftUI

struct CVBuilderView: View {
    @StateObject private var viewModel = CVViewModel()
    @StateObject private var speechService = SpeechRecognitionService()
    @StateObject private var aiService = AITextService()
    @State private var currentQuestionIndex = 0
    @State private var showVoiceInput = false
    @State private var showAIHelp = false
    @State private var textToImprove = ""
    @State private var currentContext = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack {
            ProgressView(value: Double(currentQuestionIndex), total: 6)
                .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Titolo
                    Text("Crea il tuo CV digitale")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Campo nome
                    SimpleInputField(
                        title: "Nome Completo",
                        placeholder: "Il tuo nome",
                        text: Binding(
                            get: { viewModel.cv?.personalInfo.name ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.name = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ),
                        icon: "person.fill",
                        showMic: true,
                        onMicTap: {
                            showVoiceInput = true
                            // Imposta il contesto per l'input vocale
                        },
                        showAI: true,
                        onAITap: {
                            textToImprove = viewModel.cv?.personalInfo.name ?? ""
                            currentContext = "personalInfo"
                            showAIHelp = true
                        }
                    )
                    
                    // Campo titolo professionale
                    SimpleInputField(
                        title: "Titolo Professionale",
                        placeholder: "es. Sviluppatore iOS, Designer UX",
                        text: Binding(
                            get: { viewModel.cv?.personalInfo.title ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.title = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ),
                        icon: "briefcase.fill",
                        showMic: true,
                        onMicTap: {
                            showVoiceInput = true
                            // Imposta il contesto per l'input vocale
                        },
                        showAI: true,
                        onAITap: {
                            textToImprove = viewModel.cv?.personalInfo.title ?? ""
                            currentContext = "personalInfo"
                            showAIHelp = true
                        }
                    )
                    
                    // Campo email
                    SimpleInputField(
                        title: "Email",
                        placeholder: "La tua email",
                        text: Binding(
                            get: { viewModel.cv?.personalInfo.email ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.email = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ),
                        icon: "envelope.fill",
                        showMic: false,
                        showAI: false
                    )
                    
                    // Campo telefono
                    SimpleInputField(
                        title: "Telefono",
                        placeholder: "Il tuo numero",
                        text: Binding(
                            get: { viewModel.cv?.personalInfo.phone ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.phone = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ),
                        icon: "phone.fill",
                        showMic: true,
                        onMicTap: {
                            showVoiceInput = true
                        },
                        showAI: false
                    )
                    
                    // Campo location
                    SimpleInputField(
                        title: "Località",
                        placeholder: "es. Milano, Italia",
                        text: Binding(
                            get: { viewModel.cv?.personalInfo.location ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.location = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ),
                        icon: "location.fill",
                        showMic: true,
                        onMicTap: {
                            showVoiceInput = true
                        },
                        showAI: false
                    )
                    
                    // Campo sommario
                    VStack(alignment: .leading) {
                        Text("Descrizione Personale")
                            .font(.headline)
                        
                        TextEditor(text: Binding(
                            get: { viewModel.cv?.personalInfo.summary ?? "" },
                            set: { 
                                if var cv = viewModel.cv {
                                    cv.personalInfo.summary = $0
                                    viewModel.updatePersonalInfo(cv.personalInfo)
                                }
                            }
                        ))
                        .frame(height: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack {
                            // Pulsante per registrazione vocale
                            Button(action: {
                                showVoiceInput = true
                            }) {
                                Label("Dettatura", systemImage: "mic.fill")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Pulsante per miglioramento AI
                            Button(action: {
                                textToImprove = viewModel.cv?.personalInfo.summary ?? ""
                                currentContext = "personalInfo"
                                showAIHelp = true
                            }) {
                                Label("Migliora", systemImage: "wand.and.stars")
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .disabled(viewModel.cv?.personalInfo.summary?.isEmpty ?? true)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // Pulsante salva
                    Button(action: {
                        viewModel.updateCV()
                        showSuccessAlert = true
                    }) {
                        Text("Salva Informazioni")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            
            // Overlay per input vocale
            if showVoiceInput {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Text("Dettatura Vocale")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding()
                            
                            Text(speechService.isRecording ? "Sto ascoltando..." : "Premi per iniziare")
                            
                            Text(speechService.transcript)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .padding()
                            
                            HStack {
                                Button(action: {
                                    if speechService.isRecording {
                                        speechService.stopRecording()
                                    } else {
                                        speechService.startRecording()
                                    }
                                }) {
                                    Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 30))
                                        .padding()
                                        .background(speechService.isRecording ? Color.red : Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: {
                                    showVoiceInput = false
                                }) {
                                    Text("Chiudi")
                                        .padding()
                                }
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(30)
                    )
            }
            
            // Overlay per miglioramento AI
            if showAIHelp {
                // Interfaccia simile all'input vocale per l'aiuto AI
            }
        }
        .navigationTitle("Crea CV")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Salvato!"),
                message: Text("Le informazioni sono state salvate con successo."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SimpleInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let showMic: Bool
    var onMicTap: (() -> Void)? = nil
    let showAI: Bool
    var onAITap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                TextField(placeholder, text: $text)
                    .padding(.vertical, 12)
                
                if showMic {
                    Button(action: {
                        onMicTap?()
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 8)
                }
                
                if showAI && !text.isEmpty {
                    Button(action: {
                        onAITap?()
                    }) {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}

struct CVBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CVBuilderView()
        }
    }
} 