import Foundation
import Speech
import Combine

class SpeechRecognitionService: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var errorMessage = ""
    @Published var permissionGranted = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "it-IT"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch status {
                case .authorized:
                    self.permissionGranted = true
                    self.errorMessage = ""
                case .denied:
                    self.permissionGranted = false
                    self.errorMessage = "Permesso negato per il riconoscimento vocale"
                case .restricted:
                    self.permissionGranted = false
                    self.errorMessage = "Il riconoscimento vocale è limitato su questo dispositivo"
                case .notDetermined:
                    self.permissionGranted = false
                    self.errorMessage = "Il riconoscimento vocale non è stato ancora autorizzato"
                @unknown default:
                    self.permissionGranted = false
                    self.errorMessage = "Errore sconosciuto nell'autorizzazione"
                }
            }
        }
    }
    
    func startRecording() {
        // Controlla se il riconoscimento è già in corso
        if isRecording {
            stopRecording()
            return
        }
        
        // Verifica se il riconoscitore è disponibile
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Il riconoscimento vocale non è disponibile in questo momento"
            return
        }
        
        // Verifica il permesso
        if !permissionGranted {
            checkPermission()
            return
        }
        
        // Configura la sessione audio
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Errore nella configurazione della sessione audio: \(error.localizedDescription)"
            return
        }
        
        // Inizializza e configura la richiesta di riconoscimento
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Verifica che il nodo di input audio sia disponibile
        guard let inputNode = audioEngine.inputNode else {
            errorMessage = "Il dispositivo non ha un microfono"
            return
        }
        
        // Assicurati che la richiesta di riconoscimento sia valida
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Impossibile creare la richiesta di riconoscimento"
            return
        }
        
        // Configura la richiesta
        recognitionRequest.shouldReportPartialResults = true
        
        // Inizia il task di riconoscimento
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isRecording = false
            }
        }
        
        // Configura il formato audio e inizia a registrare
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Avvia il motore audio
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
            errorMessage = ""
        } catch {
            errorMessage = "Errore nell'avvio del motore audio: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    func resetTranscript() {
        transcript = ""
    }
} 