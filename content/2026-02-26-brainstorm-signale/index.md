---
author: Edgar (Zong)
author_bio: >
  Dipl-Informatiker
  Rentner
tags: ["Stage 3", "Brainstorming", "Entwicklung", "Konzepte", "Signale", "Lokalisierung"]
---

# Brainstorming: Strategien zum Lokalisieren der Gems in Stage 3 Resonance

Das Lokalisieren der Gems in Stage 3 Resonance ist durch das Rauschen erschwert. In diesem Blog stelle ich einige Strategien vor, die mir dazu eingefallen sind. Es gibt natürlich viele weitere Konzepte, die deutlich komplizierter sind oder mir nicht eingefallen sind.

Keine der hier vorgestellten Strategien kann den Gem auf mittlere oder große Entfernung genau lokalisieren. Das Ziel besteht darin, das Gebiet, in dem sich der Gem befindet, auf einen kleinen Bereich zu reduzieren. Anschließend kann der Bot zu diesem Gebiet laufen und den Gem weiter einkreisen und einsammeln.

Ein Bereich wird als besser bezeichnet, wenn seine maximale Ausdehnung kleiner ist. Ein Quadrat mit 9 Feldern ist somit besser als ein Rechteck mit 1 × 9 Feldern.

# Strategien

## A) Stehen bleiben

Der Bot bleibt stehen und erfasst mehrere Signalwerte. Aus diesen lässt sich eine Schätzung für den wahren Wert berechnen. Die einfachste Methode ist die Mittelwertbildung. Zusätzlich können Extremwerte herausgefiltert werden.

Der Mittelwert kann jedoch nur berechnet werden, wenn der Gem seine volle Signalstärke erreicht hat. So erhält man einen guten Schätzwert für die Entfernung und den zugehörigen Fehler. Der Zielbereich ist ein Kreisring. Das ist schlecht, da man die Richtung nicht kennt.

Zudem befinden sich mehr als ein Gem auf der Karte, sodass das Stehenbleiben das Einsammeln der anderen Gems verhindert.


## B) Trigonometrie

Der Bot läuft von A aus geradeaus nach B und dann entweder rechts oder links nach C. In Stage 2 reicht jeweils ein Schritt. In Stage 3 sind hingegen mehrere Schritte von A nach B und von B nach C erforderlich. An den Punkten A, B und C werden die Kreisringe berechnet, deren Schnittmenge den Zielbereich bildet. Zur Verfeinerung können die Zwischenpunkte hinzugezogen werden.

Wird die Schrittweite zu klein gewählt, erhält man statt eines schönen Bereichs einen exzentrischen Ring oder eine Mondsichel. Bei einem zu kleinen Fehler liegt der Gem zu weit weg vom Bereich. Da der Bereich anfangs groß ist, muss die Messung mehrmals durchgeführt werden, wenn sich der Bot dem Bereich genähert hat.

Das Einsammeln der anderen Gems stört nicht, da der Weg zu ihnen entsprechend gewählt werden kann. Die Wände stören jedoch etwas und der Weg muss mit Weitsicht geplant werden.


## C) Walker

Wie Paul (Phnt0m) in seinem [Blog](https://hiddengems.gymnasiumsteglitz.de/blog/2026-01-20-mit-zufall-ans-ziel) beschrieben hat, werden Walker auf der Karte verteilt, die sich dem Gem nähern. Hier müssen die Walker lediglich dem Signal eines Gems folgen. Genaueres entnehmt bitte seinem Blog.

Die Walker arbeiten mit Wahrscheinlichkeiten und einer Temperatur. Das Rauschen ist nur eine weitere Wahrscheinlichkeit für sie. Zu beachten ist, dass die Walker über mehrere Ticks am Leben gehalten werden und teilweise weite Wege zurücklegen. Da das aktuelle Signal zu wenig Informationen enthält, sollte im Vorfeld für jedes Feld der Karte ein Wahrscheinlichkeitswert berechnet werden, der auch die vergangenen Werte mit einbezieht. Dies ist sehr rechenintensiv und sollte bezüglich der Timeouts im Auge behalten werden.

Bis sich genügend Walker in einem Bereich gesammelt haben, sind nur wenige Informationen über den Abstand oder die Richtung des Gems verfügbar (meine Erfahrung). Dann jedoch ist es ein guter Bereich, der konstant kleiner wird.


## D) Wahrscheinlichkeitsberechnung

Für jedes Feld der Karte wird die Wahrscheinlichkeit berechnet, dass sich dort ein Gem befindet. Bei jedem Tick wird die neue Wahrscheinlichkeit mit dem Wert der alten Wahrscheinlichkeit multipliziert. Eine Alternative, die schneller und unkomplizierter ist, besteht darin, den Fehler aufzuaddieren.

Dies ist vergleichbar mit der Vorberechnung aus C). Auch hier ist die Rechenzeit zu beobachten. Zusätzlich muss hier die Liste der Felder sortiert werden. Das Verfahren gibt keinen Zielbereich direkt vor.

Wenn nur das Feld mit der höchsten Wahrscheinlichkeit gewählt wird, kann es zu lustigen Effekten kommen. So lief mein Bot beispielsweise häufig einen Kreis mit einem Durchmesser von vier oder fünf Feldern ab, bevor er zu dem Gem lief. Mit etwas Geschick kann man jedoch ein Intervall bestimmen, dessen Felder den Zielbereich bilden. Dieser wird dann immer kleiner.


## E) Einfacher Filter

Man nimmt eine Liste mit Feldern (anfangs sind alle Felder enthalten) und berechnet für jedes Feld den Fehler, der hier auftreten würde, wenn ein Gem vorhanden wäre. Wird ein zuvor berechneter Grenzwert überschritten, wird das Feld aus der Liste entfernt. Die Liste stellt somit den Zielbereich dar.

Extremwerte des Rauschens können dazu führen, dass die Liste leer wird. In diesem Fall kann das Signal als Extremwert ignoriert und die Liste des letzten Ticks verwendet werden. Um sicherzugehen, dass das Rauschen des letzten Ticks das Gem nicht bereits ausgefiltert hat, kann auf den vorletzten Tick zurückgegriffen werden.


## F) Adaptive Filter

Anders als bei Strategie E) werden zwei Listen parallel geführt, die unterschiedlich streng filtern.

Der erste Filter hat große Grenzen und entfernt nur offensichtlich falsche Werte aus der Liste, sodass selbst starkes Rauschen diese nicht leert. Wichtig ist, dass die Grenzen groß genug sind, damit der Gem garantiert nicht herausfällt. Ein starkes Rauschen kann viele Felder entfernen, die normalerweise nicht gefiltert würden. Es ist deshalb erwünscht.

Der zweite Filter hat enge Grenzen und soll den Zielbereich schnell verkleinern. Bei starkem Rauschen kann seine Liste leer werden. Der entscheidende Unterschied zu E) besteht darin, dass in diesem Fall nicht auf eine frühere Liste zurückgegriffen wird, sondern die aktuelle Liste des ersten Filters genutzt wird. Diese enthält viele Einträge, die eigentlich hätten gefiltert werden sollen. Dies wird beim nächsten Filterdurchlauf erledigt. Allerdings sind einige falsche Felder nicht mehr enthalten, die der zweite Filter nicht so schnell entfernen könnte.


## G) Sieb

Die Felder werden in verschiedene Güteklassen (zum Beispiel I bis X) eingeteilt. Das Zielgebiet ist die höchste Klasse I, während die niedrigste Klasse die Felder enthält, die sehr unwahrscheinlich sind und nicht mehr in die Berechnung eingehen.

Zu Beginn wird jedes Feld einer Klasse zugeordnet. In jeder weiteren Berechnung (Tick) kann ein Feld seine Klasse behalten oder um eine Klasse auf- bzw. absteigen. Dadurch werden Schwankungen der Rauschstärke abgefangen. Um den Zufluss in die höchste Klasse so klein wie möglich und so groß wie nötig zu halten, gelten für den Aufstieg strengere Kriterien.


## H) Große Felder

Die genaue Position des Gems muss nicht bekannt sein, um ihn einzusammeln. Eine ungefähre Position reicht aus, denn wenn der Bot dort ankommt, erkennt er ihn. Anstelle der einzelnen Felder werden jetzt 3x3-Feld-Quadrate zusammengefasst. Andere Größen sind auch möglich. Es gibt wieder zwei Möglichkeiten: überlappende oder nicht überlappende Quadrate.

Das Quadrat hat für die Berechnung nicht einen, sondern zwei Mittelpunkte. Einen für das dem Bot am nächsten gelegene Feld und einen für das am weitesten entfernte Quadrat. Für die Berechnung eines Signals ist nur die Entfernung wichtig. Die kleinere Entfernung wird mit der unteren Schranke und die größere mit der oberen abgeglichen.

Dies ist an sich noch kein Verfahren zur Lokalisierung. Hierzu muss eine der Strategien C) bis F) auf die Quadrate angewendet werden. Die Vorteile sind neben der geringeren Rechenzeit (2 statt 9 Berechnungen, Listen sind um 1/9 kleiner), dass die Quadrate teilweise auf Wänden liegen können und Gems somit einfacher in engen Gängen zu lokalisieren sind.


# Allgemeines

## Testen

Zum Testen der Algorithmen verwendet bitte immer eine Karte ohne Wände und genau ein Gem. Programmiert zunächst auch nichts mit Wänden oder Sicht hinein. Das kann später erfolgen, wenn es auf dieser Karte funktioniert.

Wenn der Test erfolgreich war, nehmt eine Karte mit Wänden und weiterhin genau ein Gem. Wenn alles läuft, könnt ihr nun mehrere Gems nehmen.

Zum Abschluss empfehle ich den Seed 1 mit einem Gem. Später mit sieben Gems. Dieser Seed ist einfach zu merken und hart.


## Wände

Wände können den Zielbereich weiter eingrenzen. Leider können Wände auch nachteilig sein, da sich der Zielbereich auf zwei Seiten einer Wand befinden kann.

Einige Strategien funktionieren besser, wenn man Wände und/oder Sicht ignoriert, andere nicht.


## Bewegung

Die Bewegung des Bots ist wichtig, um einen guten, kleinen Zielbereich zu erhalten. Anfangs ist er ein Kreisring, doch schnell wird er zu einer Mondsichel. Es ist nicht einfach, die Mondsichel in einen schönen kleinen Bereich zu verwandeln. Der Bot muss sich schließlich auf die anderen Gems bewegen.


## Abschluß

Ich habe die Strategien C) bis H) programmiert und in meinen Test-Bot eingebaut. (Ich liebe das Programmieren.) Die Strategien D) bis G) sind sehr einfach und schnell erstellt. C) und H) sind mittlere Komplexität. Der Test-Bot hat die Wegfindung und das Zielhandling aus Stage 2, und ist lediglich um das Anlaufen von Ziel-Bereichen erweitert.

Der Abschlusstest war profile seed qmss8jxf1 von den Scrims vom 21. Februar 2026. Ohne die Parameter optimal einzustellen, erreichten die obigen Strategien einen Score von 240.000 bis 255.000. Der beste Bot in den Scrims hatte einen Score von 261.990.

Ich hoffe, ich konnte euch weiterhelfen, falls ihr noch keine klare Idee habt, wie ihr die Gems lokalisiert. Oder falls ihr bereits eine der genannten Strategien benutzt, die Bestätigung geben, dass sie funktioniert. Natürlich funktionieren auch andere, nicht genannte Strategien.


Edgar (aka Zong)
