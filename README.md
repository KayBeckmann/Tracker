# Tracker App

Eine plattformübergreifende Produktivitäts-App, die mit Flutter und Dart entwickelt wurde. Sie hilft Ihnen, Aufgaben, Notizen, Gewohnheiten und Finanzen zu verwalten.

## Funktionen

-   **Aufgabenverwaltung:** Erfassen, bearbeiten und löschen Sie Aufgaben mit Fälligkeitsdaten und Prioritäten.
-   **Notizen:** Erstellen und verwalten Sie Notizen mit Markdown-Unterstützung und Tags.
-   **Gewohnheiten:** Verfolgen und verwalten Sie Ihre Gewohnheiten mit Streak- und Level-Systemen.
-   **Dashboard:** Eine Übersicht über Ihre Aufgaben, Notizen und Gewohnheiten.

## Erste Schritte

### Voraussetzungen

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installiert und konfiguriert.

### Installation

1.  Klonen Sie das Repository:
    ```bash
    git clone <repository-url>
    cd tracker
    ```
2.  Abhängigkeiten installieren:
    ```bash
    flutter pub get
    ```
3.  Generieren Sie die Hive-Adapter:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

### App starten

```bash
flutter run
```

## Projektstruktur

-   `lib/models/`: Datenmodelle (z.B. Task, Note).
-   `lib/services/`: Dienste für die Datenbankinteraktion.
-   `lib/`: UI-Seiten und Hauptanwendungslogik.