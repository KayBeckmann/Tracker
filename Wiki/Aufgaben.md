# Aufgaben

Die Aufgaben-Seite ermöglicht die Verwaltung aller Aufgaben.

## Aufbau

Die Seite zeigt eine Liste aller Aufgaben an. Jede Aufgabe wird mit Beschreibung, Fälligkeitsdatum und Priorität dargestellt. Es gibt Optionen zum Sortieren der Aufgaben nach Fälligkeitsdatum oder Priorität und zum Ein- oder Ausblenden erledigter Aufgaben. Für jede Aufgabe gibt es Kontrollkästchen zum Markieren als erledigt, Bearbeiten-Buttons und Löschen-Buttons. Ein "+"-Button (Floating Action Button) ermöglicht das Hinzufügen neuer Aufgaben.

## Funktionsweise

Aufgaben werden über den `DatabaseService` geladen, gespeichert, aktualisiert und gelöscht. Beim Laden der Seite werden alle Aufgaben abgerufen und entsprechend der gewählten Sortierreihenfolge und Filteroption (erledigte Aufgaben anzeigen/ausblenden) angezeigt. Das Bearbeiten oder Hinzufügen einer Aufgabe navigiert zur `TaskEditPage`. Das Markieren einer Aufgabe als erledigt oder das Löschen einer Aufgabe aktualisiert die Datenbank und die angezeigte Liste.
