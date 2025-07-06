# Gewohnheiten

Diese Seite ist für die Verwaltung von Gewohnheiten vorgesehen.

## Aufbau

Die Seite zeigt eine Liste aller Gewohnheiten an. Jede Gewohnheit wird mit ihrer Beschreibung, dem aktuellen Streak (Anzahl der aufeinanderfolgenden Tage, an denen die Gewohnheit abgehakt wurde) und dem Level angezeigt. Für jede Gewohnheit gibt es Buttons zum Abhaken, Bearbeiten und Löschen. Ein "+"-Button (Floating Action Button) ermöglicht das Hinzufügen neuer Gewohnheiten.

## Funktionsweise

Gewohnheiten werden über den `HabitService` verwaltet. Beim Abhaken einer Gewohnheit wird der Streak aktualisiert. Wenn eine Gewohnheit an einem Tag nicht abgehakt wird, wird der Streak auf 0 zurückgesetzt. Alle 7 Streaks erhöht sich das Level um 1. Wenn der Streak auf 0 gesetzt wird, verringert sich das Level um 1 (nicht kleiner als 0). Die Bearbeitung und das Hinzufügen neuer Gewohnheiten erfolgt über die `HabitEditPage`.