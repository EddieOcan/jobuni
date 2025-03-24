# JobUni - Curriculum Digitale per iOS

Un'applicazione iOS moderna per creare, gestire e condividere il tuo curriculum vitae professionale.

## Caratteristiche

- **Registrazione e Accesso**: Sistema di autenticazione completo con profilo personale
- **Interfaccia moderna e minimalista**: Design ispirato a Notion con un'interfaccia pulita e facile da usare
- **Raccolta dati intuitiva**: Processi guidati per inserire tutte le informazioni del CV
- **Riconoscimento vocale**: Inserimento dei dati tramite dettatura
- **Miglioramenti IA**: Elaborazione dei testi per renderli più professionali
- **Sito web personale**: Generazione automatica di un sito web con il tuo curriculum
- **Esportazione PDF**: Esporta il tuo CV in formato PDF direttamente dall'app

## Requisiti tecnici

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+
- Account Firebase per il backend

## Configurazione Firebase

1. Crea un nuovo progetto su [Firebase Console](https://console.firebase.google.com/)
2. Aggiungi una nuova app iOS
3. Scarica il file `GoogleService-Info.plist` e aggiungilo al progetto
4. Abilita i seguenti servizi Firebase:
   - Authentication (email/password)
   - Firestore Database
   - Storage
   - Hosting (per il sito web personale)

## Struttura del database Firestore

### Collezione "users"
Memorizza le informazioni degli utenti:
```
users/
  {userId}/
    name: String
    email: String
    photoURL: String (opzionale)
    createdAt: Timestamp
```

### Collezione "cvs"
Memorizza i dati dei curriculum:
```
cvs/
  {cvId}/
    userID: String (riferimento all'utente)
    personalInfo: {
      name: String
      email: String
      phone: String
      location: String
      title: String
      summary: String
      photoURL: String
    }
    education: [
      {
        id: String
        degree: String
        institution: String
        location: String
        startDate: Timestamp
        endDate: Timestamp (opzionale)
        isCurrentlyStudying: Boolean
        description: String
        color: String
      }
    ]
    experience: [
      {
        id: String
        position: String
        company: String
        location: String
        startDate: Timestamp
        endDate: Timestamp (opzionale)
        isCurrentlyWorking: Boolean
        description: String
        achievements: [String]
        color: String
      }
    ]
    skills: [
      {
        id: String
        name: String
        level: Number (1-5)
        category: String
      }
    ]
    languages: [
      {
        id: String
        name: String
        proficiency: String
      }
    ]
    createdAt: Timestamp
    updatedAt: Timestamp
```

## Regole di sicurezza Firestore

Ecco un esempio di regole di sicurezza da configurare in Firebase:

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

## Regole di sicurezza Storage

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

## Funzionalità future

- Integrazione con LinkedIn per importare dati
- Opzioni di personalizzazione avanzate (temi, font, colori)
- Più template per il sito web personale
- Analisi delle visite al CV online
- Supporto per più lingue

## Crediti

Sviluppato come progetto dimostrativo per un'applicazione iOS moderna con funzionalità di intelligenza artificiale e interfaccia utente elegante. 