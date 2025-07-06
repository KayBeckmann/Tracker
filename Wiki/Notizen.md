# Notizen

Die Notizen-Seite dient zur Verwaltung und Anzeige aller Notizen.

## Aufbau

Die Seite zeigt eine Liste von Notizen an. Jede Notiz wird mit einem Titel (der ersten Zeile des Notiztextes) und einer Vorschau (den nächsten zwei Zeilen) dargestellt. Wenn Tags vorhanden sind, werden diese ebenfalls angezeigt. Es gibt eine Option, Notizen nach Tags zu filtern. Für jede Notiz gibt es Buttons zum Bearbeiten und Löschen. Ein "+"-Button (Floating Action Button) ermöglicht das Hinzufügen neuer Notizen.

## Funktionsweise

Notizen werden über den `NoteService` geladen, gespeichert, aktualisiert und gelöscht. Beim Laden der Seite werden alle Notizen abgerufen. Wenn ein Tag ausgewählt ist, werden die Notizen nach diesem Tag gefiltert. Das Bearbeiten oder Hinzufügen einer Notiz navigiert zur `NoteEditPage`. Das Anzeigen einer Notiz navigiert zur `NoteReadPage`. Das Löschen einer Notiz aktualisiert die Datenbank und die angezeigte Liste.
