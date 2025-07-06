# Dashboard

Das Dashboard bietet einen schnellen Überblick über wichtige Informationen und Statistiken der Anwendung.

## Aufbau

Das Dashboard besteht aus mehreren Karten (Cards), die verschiedene Übersichten anzeigen:
- **Aufgabenübersicht**: Zeigt die Gesamtzahl der Aufgaben und die Anzahl der Aufgaben mit hoher Priorität.
- **Nächste fällige Aufgabe**: Zeigt Details zur nächsten anstehenden Aufgabe an und bietet die Möglichkeit, diese als erledigt zu markieren.
- **Notizenübersicht**: Zeigt die Gesamtzahl der Notizen und die häufigsten Tags an. Tags können angeklickt werden, um direkt zur Notizen-Seite mit dem entsprechenden Filter zu springen.

## Funktionsweise

Beim Laden der Seite werden Daten von `DatabaseService` (für Aufgaben) und `NoteService` (für Notizen) abgerufen. Diese Daten werden dann verarbeitet und auf den entsprechenden Karten angezeigt. Interaktionen wie das Markieren einer Aufgabe als erledigt oder das Klicken auf einen Tag aktualisieren die angezeigten Informationen und können zu anderen Seiten navigieren.
