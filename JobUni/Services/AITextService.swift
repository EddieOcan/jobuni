import Foundation
import Combine

class AITextService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var apiKey: String {
        // In un'applicazione reale, questo valore dovrebbe essere nascosto o gestito in modo sicuro
        return ""
    }
    
    // L'URL dell'API OpenAI (esempio)
    private let openAIURL = URL(string: "https://api.openai.com/v1/completions")!
    
    /// Migliora un testo per un CV utilizzando AI
    /// - Parameters:
    ///   - text: Il testo originale da migliorare
    ///   - context: Il contesto (es. "esperienza lavorativa", "formazione", ecc.)
    ///   - completion: Il callback con il testo migliorato o un errore
    func improveText(text: String, context: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Se l'API key non è impostata, utilizza una semplice elaborazione locale
        if apiKey.isEmpty {
            // Implementazione locale per simulare l'elaborazione AI
            DispatchQueue.global().async {
                let improvedText = self.localImproveText(text: text, context: context)
                DispatchQueue.main.async {
                    completion(.success(improvedText))
                }
            }
            return
        }
        
        // Altrimenti usa OpenAI API
        isLoading = true
        
        // Crea il prompt per l'API
        let prompt = "Migliora il seguente testo per un curriculum vitae nel contesto di '\(context)':\n\n\(text)\n\nMiglioramento:"
        
        // Prepara la richiesta
        var request = URLRequest(url: openAIURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Parametri per la richiesta
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo-instruct", // Usa un modello appropriato
            "prompt": prompt,
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        // Serializza i parametri
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Errore nella preparazione della richiesta: \(error.localizedDescription)"
                completion(.failure(error))
            }
            return
        }
        
        // Esegui la richiesta
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Errore di rete: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "AITextService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nessun dato ricevuto"])
                    self.errorMessage = "Nessun dato ricevuto"
                    completion(.failure(error))
                    return
                }
                
                do {
                    // Decodifica la risposta
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let text = firstChoice["text"] as? String {
                        
                        // Pulisci il testo da spazi iniziali e finali
                        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        completion(.success(cleanedText))
                    } else {
                        let error = NSError(domain: "AITextService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossibile estrarre il testo dalla risposta"])
                        self.errorMessage = "Formato di risposta non valido"
                        completion(.failure(error))
                    }
                } catch {
                    self.errorMessage = "Errore nella decodifica della risposta: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    /// Implementazione locale per simulare l'elaborazione AI (quando l'API key non è disponibile)
    private func localImproveText(text: String, context: String) -> String {
        // Questa è una semplice simulazione di miglioramento del testo
        // In un'app reale, utilizzerai le vere API AI o implementazioni locali più sofisticate
        
        var improvedText = text
        
        // Rendi il testo più professionale
        improvedText = improvedText.replacingOccurrences(of: "ho fatto", with: "ho realizzato")
        improvedText = improvedText.replacingOccurrences(of: "ho lavorato", with: "ho contribuito")
        
        // Aggiungi elementi specifici per il contesto
        switch context.lowercased() {
        case "esperienza lavorativa":
            if !improvedText.contains("responsabile") && !improvedText.contains("responsabilità") {
                improvedText += " In questa posizione, ho assunto la responsabilità di gestire efficacemente i compiti assegnati."
            }
        case "formazione":
            if !improvedText.contains("competenz") {
                improvedText += " Durante questo percorso formativo, ho acquisito competenze teoriche e pratiche nel settore."
            }
        case "competenze":
            if !improvedText.contains("capacità") {
                improvedText += " Questa competenza mi permette di affrontare efficacemente le sfide professionali."
            }
        default:
            break
        }
        
        return improvedText
    }
} 