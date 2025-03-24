import SwiftUI
import PDFKit

struct CVPreviewView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CVViewModel()
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    @State private var isGeneratingPDF = false
    
    var body: some View {
        ZStack {
            // Sfondo
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Intestazione
                    VStack(spacing: 5) {
                        Text(viewModel.cv?.personalInfo.name ?? "Nome Cognome")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text(viewModel.cv?.personalInfo.title ?? "Titolo Professionale")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 15) {
                            if let email = viewModel.cv?.personalInfo.email, !email.isEmpty {
                                Label(email, systemImage: "envelope.fill")
                                    .font(.caption)
                            }
                            
                            if let phone = viewModel.cv?.personalInfo.phone, !phone.isEmpty {
                                Label(phone, systemImage: "phone.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 5)
                        
                        if let location = viewModel.cv?.personalInfo.location, !location.isEmpty {
                            Label(location, systemImage: "location.fill")
                                .font(.caption)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Sommario
                    if let summary = viewModel.cv?.personalInfo.summary, !summary.isEmpty {
                        CVSection(title: "Chi sono", content: summary)
                    }
                    
                    // Formazione
                    if let education = viewModel.cv?.education, !education.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Formazione")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            ForEach(education) { item in
                                EducationCard(education: item)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Esperienze
                    if let experiences = viewModel.cv?.experience, !experiences.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Esperienze Lavorative")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            ForEach(experiences) { item in
                                ExperienceCard(experience: item)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Competenze
                    if let skills = viewModel.cv?.skills, !skills.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Competenze")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                                ForEach(skills) { skill in
                                    SkillBadge(skill: skill)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Lingue
                    if let languages = viewModel.cv?.languages, !languages.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Lingue")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                                ForEach(languages) { language in
                                    LanguageBadge(language: language)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Pulsanti azione
                    HStack(spacing: 15) {
                        Button(action: {
                            isGeneratingPDF = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.generatePDF()
                                isGeneratingPDF = false
                                showShareSheet = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.doc.fill")
                                Text("Scarica PDF")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Condivisione del link al sito web
                        }) {
                            HStack {
                                Image(systemName: "link")
                                Text("Condividi Link")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            
            if isGeneratingPDF {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Generazione del PDF in corso...")
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .navigationTitle("Anteprima CV")
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.loadCV(userId: userId)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }
    
    private func generatePDF() {
        // In un'implementazione reale, questo genererebbe un vero PDF
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0))
        
        pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Esempio di render del testo
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            
            let nameText = viewModel.cv?.personalInfo.name ?? "Nome Cognome"
            nameText.draw(at: CGPoint(x: 50, y: 50), withAttributes: attributes)
            
            // Qui aggiungerei il resto del contenuto del PDF
            
            // Per ora ritorniamo solo un semplice documento
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
            ]
            
            let titleText = viewModel.cv?.personalInfo.title ?? "Titolo Professionale"
            titleText.draw(at: CGPoint(x: 50, y: 80), withAttributes: titleAttributes)
        }
    }
}

struct CVSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(content)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EducationCard: View {
    let education: Education
    
    var dateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        
        let startDateString = dateFormatter.string(from: education.startDate)
        
        if education.isCurrentlyStudying {
            return "\(startDateString) - Presente"
        } else if let endDate = education.endDate {
            let endDateString = dateFormatter.string(from: endDate)
            return "\(startDateString) - \(endDateString)"
        } else {
            return startDateString
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(education.degree)
                        .font(.headline)
                    
                    Text(education.institution)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !education.location.isEmpty {
                Text(education.location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !education.description.isEmpty {
                Text(education.description)
                    .font(.body)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(colorForCard(color: education.color).opacity(0.1))
        .cornerRadius(8)
    }
    
    func colorForCard(color: String) -> Color {
        switch color.lowercased() {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        default:
            return .blue
        }
    }
}

struct ExperienceCard: View {
    let experience: WorkExperience
    
    var dateText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        
        let startDateString = dateFormatter.string(from: experience.startDate)
        
        if experience.isCurrentlyWorking {
            return "\(startDateString) - Presente"
        } else if let endDate = experience.endDate {
            let endDateString = dateFormatter.string(from: endDate)
            return "\(startDateString) - \(endDateString)"
        } else {
            return startDateString
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(experience.position)
                        .font(.headline)
                    
                    Text(experience.company)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !experience.location.isEmpty {
                Text(experience.location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !experience.description.isEmpty {
                Text(experience.description)
                    .font(.body)
                    .padding(.top, 5)
            }
            
            if !experience.achievements.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Risultati:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.top, 5)
                    
                    ForEach(experience.achievements, id: \.self) { achievement in
                        Text("• \(achievement)")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(colorForCard(color: experience.color).opacity(0.1))
        .cornerRadius(8)
    }
    
    func colorForCard(color: String) -> Color {
        switch color.lowercased() {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        case "red":
            return .red
        default:
            return .green
        }
    }
}

struct SkillBadge: View {
    let skill: Skill
    
    var body: some View {
        HStack {
            Text(skill.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= skill.level ? "circle.fill" : "circle")
                    .foregroundColor(colorForCategory(skill.category))
                    .font(.system(size: 8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(colorForCategory(skill.category).opacity(0.1))
        .cornerRadius(15)
    }
    
    func colorForCategory(_ category: SkillCategory) -> Color {
        switch category {
        case .technical:
            return .blue
        case .soft:
            return .purple
        case .language:
            return .green
        case .other:
            return .orange
        }
    }
}

struct LanguageBadge: View {
    let language: Language
    
    var body: some View {
        HStack {
            Text(language.name)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(language.proficiency.rawValue)
                .font(.system(size: 10))
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct CVPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CVPreviewView()
                .environmentObject(AuthViewModel())
        }
    }
} 