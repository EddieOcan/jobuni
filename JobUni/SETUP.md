# Istruzioni di Setup per JobUni

Ecco i passaggi necessari per configurare l'ambiente di sviluppo e far funzionare l'applicazione JobUni sul tuo ambiente locale.

## Prerequisiti

- [Xcode](https://apps.apple.com/it/app/xcode/id497799835) versione 12.0 o superiore
- [CocoaPods](https://cocoapods.org/) per la gestione delle dipendenze
- Un account [Firebase](https://firebase.google.com/) (è possibile utilizzare il piano gratuito)
- Un dispositivo o simulatore iOS con iOS 14.0 o superiore

## Configurazione del progetto

### 1. Clona il repository

```bash
git clone <repository-url>
cd applicazione_ios
```

### 2. Configurazione Firebase

1. Vai alla [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuovo progetto (o utilizza un progetto esistente)
3. Aggiungi una nuova app iOS:
   - Inserisci il bundle ID `com.tuodominio.JobUni` (o un altro ID che preferisci)
   - Scarica il file `GoogleService-Info.plist`
   - Posiziona il file scaricato nella cartella principale del progetto
4. Attiva i seguenti servizi:
   - **Authentication**: Abilita almeno il metodo Email/Password
   - **Firestore Database**: Crea un database in modalità produzione o test
   - **Storage**: Inizializza Firebase Storage per archiviare immagini e file PDF
   - **Hosting**: Se vuoi abilitare la generazione di siti web personali

### 3. Configurazione delle regole di sicurezza

#### Firestore Database

Nella console Firebase, vai su "Firestore Database" -> "Regole" e imposta:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /cvs/{cvId} {
      allow read: if request.auth != null && resource.data.userID == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.userID == request.auth.uid;
      allow read: if resource.data.isPublic == true;
    }
  }
}
```

#### Firebase Storage

Nella console Firebase, vai su "Storage" -> "Regole" e imposta:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /cv_files/{cvId}.pdf {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Installazione delle dipendenze

Nella cartella del progetto, esegui:

```bash
pod install
```

### 5. Apri il workspace Xcode

```bash
open JobUni.xcworkspace
```

> Nota: assicurati di aprire il file `.xcworkspace` e non il file `.xcodeproj`.

### 6. Impostazione del target

In Xcode:
1. Seleziona il target "JobUni"
2. Vai su "Signing & Capabilities"
3. Assicurati di avere selezionato il tuo team di sviluppo
4. Verifica che il Bundle Identifier corrisponda a quello configurato su Firebase

### 7. Configurazione API AI (opzionale)

Se desideri utilizzare le funzioni di intelligenza artificiale con API esterne:

1. Registrati per ottenere una API key da [OpenAI](https://openai.com/) o altro servizio simile
2. Aggiungi la chiave API nel file `JobUni/Services/AITextService.swift`

## Esecuzione dell'app

1. Seleziona un simulatore o un dispositivo iOS fisico
2. Premi il pulsante di esecuzione (▶️) in Xcode

## Risoluzione dei problemi comuni

### Errore "Missing GoogleService-Info.plist"

Assicurati che il file `GoogleService-Info.plist` scaricato dalla console Firebase sia stato correttamente aggiunto al progetto.

### Errori di compilazione relativi a CocoaPods

Prova a reinstallare le dipendenze con:

```bash
pod deintegrate
pod install
```

### Errori di autenticazione Firebase

Verifica che i servizi di autenticazione siano stati correttamente configurati nella console Firebase.

## Risorse utili

- [Documentazione Firebase](https://firebase.google.com/docs)
- [Documentazione SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Documentazione CocoaPods](https://guides.cocoapods.org/)
- [Firebase iOS Quickstart](https://github.com/firebase/quickstart-ios) 