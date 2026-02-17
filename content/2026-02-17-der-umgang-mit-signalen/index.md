---
author: TheChaoticJan
author_bio: Gymnasialschüler 12. Klasse, Mathematik Leistungskurs
author_image: pfp.jpeg
tags: ["Anleitung", "Erfahrungsbericht"]
---

# Signalnutzung
## Die Signale richtig nutzen
Der mittlerweile stark eingeschränkte Sichtbereich (*vis_radius*) unserer Bots sorgt dafür, dass wir uns auf andere Faktoren verlassen müssen, und unsere aktuelle Stage, gibt uns da ein sehr mächtiges Werkzeug an die Hand: **Gemsignale**!

<div class="alert alert-info">
Dieser Artikel soll keine (!) 1 zu 1 Anleitung sein, wie man mit dem Noise Programmiertechnisch umgehen kann/soll.
Ich möchte vielmehr auf zugrundeliegende mathematische Ideen eingehen, die man verwenden kann, um sich ein Konzept zur Auflösung dieser Probleme überlegen kein.
</div>

Lasst uns also erst einmal zusammenfassen, was wir alles an Faktoren haben, die mit den Signalen zu tun haben, und was wir über diese Wissen (hier spezifisch für Stage 3 angepasst):

<div style='max-width: 100%; overflow-x: auto;'>
<table class='table table-sm'>
    <tr>
        <td><b>Faktor</b></td>
        <td><b><i>Erklärung bzw. Informationen</i></b></td>
    </tr>
    <tr>
        <td>signal_radius <br>(r)</td>
        <td>- Ausbreitungsradius des Gemsignals<br>- über die Runde ein fester Wert<br>- Wenn signal_strength = 0.5, ist der Bot genau signal_radius Einheiten entfernt</td>
    </tr>
    <tr>
        <td>channels</td>
        <td>- Die Liste an allen Kanälen, von denen Signale übermittelt werden<br>- Genauso groß wie max_gems</td>
    </tr>
    <tr>
        <td>signal_strength (bzw die Werte aus dem channels Array)</td>
        <td>- Stärke des Signals an genau diesem Punkt für genau diesen Kanal<br>- Berechnet sich mit: $s = \frac{1}{(1 + (\frac{d}{r})^2)}$ (d ist dabei die Distanz des Bots)<br>- stets zwischen 0 und 1</td>
    </tr>
    <tr>
        <td>signal_noise</td>
        <td>- die minimale/maximale Abweichung eines Signals an dem Punkt, an dem wir uns befinden<br>→ Mittlerweile Definition der Standartabweichung bei Normalverteiltem Noise ($\frac{1}{\sqrt{3}} \times$ signal_noise)</td>
    </tr>
    <tr>
        <td>signal_fade</td>
        <td>- Anzahl der Ticks, die es braucht, bis ein Gemsignal die volle Kraft erreicht hat<br><br><b>(!) Achtung</b><br>Im ersten Tick haben die Gems immer volle Signalstärke</td>
    </tr>
</table>                                      
</div>

## Wie verwende ich ein Signal korrekt?
Um uns dieser Frage stellen zu können, müssen wir erstmal alle Faktoren die wir haben herunterbrechen, und versuchen das Problem Stück für Stück anzugehen.
Ich schlage vor wir machen es wie folgt:

1. Was, wenn jedes Signal perfekt wäre?
2. Was machen wir mit mehreren Signalen auf einmal?
3. Wie gehen wir mit den geschwächten Signalen durch signal_fade um?
4. Wie gehen wir mit dem Noise um (gleichverteilt)?
5. Wie gehen wir mit dem Noise um (normalverteilt)?

Damit arbeiten wir uns immer ein Stück näher an die Komplexität des Problems heran. 
Lasst uns also anfangen!
### Was, wenn jedes Signal perfekt wäre?
Mit dieser Fragestellung ist essenziell folgendes gemeint:
- wir können uns zu 100% auf die Formel für die signal_strength verlassen
- kein anderer Faktor hat einen Einfluss auf dieses Signal (Fade, Noise)

Danach müssen wir herausfinden, welche Frage wir uns eigentlich stellen wollen.
Die große Frage ist ja, wo befindet sich der Gem, den wir suchen, jedoch scheint es keine genaue Möglichkeit zu geben, diesen Gem direkt zu finden... Vielleicht gibt es ja eine kleinere Teilfrage die wir beantworten können?

Die gibt es tatsächlich. Erinnern wir uns noch einmal an unsere Informationssammlung zurück. Daher wissen wir, dass sich die signal_strength so berechnet:

$$s = \frac{1}{(1 + (\frac{d}{r})^2)}$$ (d ist der Abstand des Bots vom Gem)

Diese Formel enthält den Abstand zwischen Bot und Gem, das heißt wir können die Frage beantworten, wie weit der Gem vom Bot entfernt ist. Dazu stellen wir diese Formel nun nach der Distanz d um (oder lassen es einen Taschenrechner machen) und kommen dabei auf folgendes Ergebnis

$$d = \pm\, r\,\times\,\sqrt{\frac{-(s-1)}{s}} \;\; \text{mit}\;\; \frac{r^2 \,\times\,(s-1)}{s}\leq0$$

Jetzt haben wir erstmal noch zwei neue Probleme:
1. wir haben zwei Möglichkeiten für die Distanz
2. wir haben irgendeine Bedingung, unter diese Formel gilt.

Glücklicherweise lösen sich diese Probleme mehr oder weniger von selbst auf. 
Für das erste Problem können wir einfach sagen, dass wir so oder so nur |${d}$| haben wollen, da eine Distanz nicht negativ sein kann. Damit haben wir das $\pm$ aufgelöst.
Die Bedingung dagegen sieht deutlich beängstigender aus, ist sie aber auch nicht. Erinnern wir uns noch einmal an signal_strength (also s) zurück. 
Dieser Wert ist so definiert: $0\leq s\leq 1$ 

Damit gilt:

$${r^2} \geq 0 \;\;\land\;\; (s-1) \leq0 \;\text{  → }\; r^2 \;\times\; (s-1) \leq 0$$

wodurch wir garantieren können, dass die Bedingung, im Falle dieses Wettbewerbs, immer stimmt, und wir sie ignorieren können.

Wir wissen also nun, wie wir die Distanz berechnen können, das gibt uns aber keinen Punkt, an dem der Gem liegen muss. Stattdessen haben wir eine Menge, die die aktuell möglichen Positionen beinhaltet ($M_a$). 
Diese Menge hat also alle Positionen, die genau unsere berechnete Distanz haben.

Nun können wir das ganze noch einmal im nächsten Tick (andere Position, andere signal_strength) wiederholen, und erhalten eine neue Menge, die alle von diesem Punkt möglichen Positionen enthält, wir nennen sie $M_n$ 

Wir können nun also unsere Menge $M_a$ neu definieren, als die Schnittmenge der beiden Mengen:

$$M_a := M_a \;\;\bigcap\;\; M_n$$

Wir können uns diese zwei Mengen auch als Kreise in der Welt vorstellen (perfekte Kreise sind es nur, da es die initialen beiden Werte sind):
![Beispiel zu Schnittmengen](Beispiel Schnittmenge.png)

Diesen Prozess wiederholen wir nun so oft, bis die Menge nur noch ein Element enthält, welches die Position des Gems sein muss. Und so schnell haben wir einen Gem gefunden, schlicht basierend auf einem Signal. **Glückwunsch!**

### Was machen wir mit mehreren Signalen auf einmal?
Die aktuelle Stage nimmt uns hierbei eine große Last ab. Wir müssen nicht mehr selbst herausfinden, aus wie vielen Gems sich ein Gesamtsignal zusammensetzt, sondern wir kriegen für jeden Gem das Signal übermittelt.

Dadurch wird das Problem der mehreren Signale sehr trivial, wir können nämlich einfach unseren zuvor angewendeten Algorithmus für alle Signale aus den Kanälen anwenden. Und das jeden Tick, somit berechnen wir die Positionen aller Gems in allen Kanälen zeitgleich! (Wir müssen nur aufpassen, die Berechnungszeiten damit nicht zu sprengen)

### Wie gehen wir mit den geschwächten Signalen um?
Der Wert des Signal Fade beeinflusst wie stark das Signal ist, das bedeutet, dass wir wieder zur Berechnungsformel bewegen müssen. Signal Fade verändert diese jetzt also wie folgt:
(ticks → Anzahl der Ticks die das Signal besteht | fade → signal_fade)

$$s = \frac{1}{(1 + (\frac{d}{r})^2)} \;\;\text{→ }\;\; s = \min(1, \frac{1}{\text{fade}} \times \text{ticks})\frac{1}{(1 + (\frac{d}{r})^2)}$$
  

Diese Formel können wir dann wieder umstellen, und kommen damit dann auf folgendes Ergebnis:

$$d = \pm\; r\times\sqrt{\frac{-(\text{fade}\times s - \text{ticks})}{\text{fade} \times s}} \;\;\text{mit}\;\; \frac{r^2 \times (\text{fade}\times s - \text{ticks})}{\text{fade}\times s} \leq 0 \;\land\; 0 \leq\frac{1}{\text{fade}}\times \text{ticks} \leq1$$


Diese Formel können wir dann einfach als Ersatz für unsere alte Berechnungsformel verwenden, müssen dabei aber natürlich bedenken, dass dies erst im zweiten Tick, in dem wir einen Gem sehen, gilt, da im ersten Tick, in dem wir das Signal bekommen, keinen Einfluss vom Signal Fade haben.

### Wie gehen wir mit dem Noise um?
Hier müssen wir die Frage jetzt auf zwei Weisen beantworten, da sich die Art des Noises heute noch einmal verändert hat, und der Noise nun normalverteilt anstatt gleichverteilt ist.

Der Ansatz ist allerdings dennoch relativ ähnlich, für beide Arten von Noise. Denn man kann bei beiden Noises einfach versuchen, alle Werte, die durch den Noise zusätzlich möglich wären mit einzubedenken.

#### Gleichverteiltes Rauschen
Beim gleichverteilten Rauschen ist es dabei noch extrem leicht. Wir wissen, dass der signal_noise Wert aus der Config das Maximum ist, um welches sich unsere signal_strength geändert haben kann.
Damit können wir dann wie folgt eine maximale Distanz, und eine minimale Distanz berechnen:

$$
d_{min} = \text{Distanz}(\text{signal} + \text{noise}) \;\;\land\;\;
d_{max} = \text{Distanz}(\text{signal} - \text{noise})
$$

Hierbei sind +/- jewails so angeordnet, da die Distanz kleiner wird, je stärker das Signal wird (und andersherum)

Wir haben nun eine minimale und eine maximale Distanz. Daraus können wir uns eine Spanne berechnen, welche alle Distanzen im Bereich des Noises beinhaltet, und damit auch den Wert, den wir haben wollen.
Somit muss nur unsere originale Menge $M_a$ nicht mehr nur durch eine Distanz, sondern durch die Menge aller Distanzen gemeinsam bestimmt werden, wodurch wir dann auf ein sinnvolles Ergebnis kommen werden

#### Normalverteiltes Rauschen
Für das normalverteilte Rauschen können wir den Ansatz leider nicht einfach 1 zu 1 kopieren, da das Signal Noise nun unendlich groß werden kann. Hier müssen wir uns nun einmal eine Normalverteilung vor Augen führen (bzw. uns an lang vergangene Stochastik Unterrichtsstunden erinnern ;D)
![Normalverteilung](normaldistribution.png)

Wir sehen hier, wie groß der Anteil der Werte ist, die jewails in x Spannen einer Standartabweichung liegen. Wir sehen auch, dass innerhalb von +/- 2 Standartabweichungen beinahe alle Werte enthalten sind. ($>90%$)

Jetzt müssen wir nur noch daran denken, dass wir die Standartabweichung bereits kennen ($\frac{1}{\sqrt{3}} \times$ signal_noise) und müssen diese dann anwenden:

$$
d_{min} = \text{Distanz}(\text{signal} + frac{1}{\sqrt{3}} \times\text{noise}) \;\;\land\;\;
d_{max} = \text{Distanz}(\text{signal} - frac{1}{\sqrt{3}} \times\text{noise})
$$

Dadurch, dass wir damit fast alle Werte abdecken, können wir immernoch davon ausgehen in einer relativ guten Zeit, mit sehr wenigen falsch positiven, einen sinnvollen Wert zu erhalten.
Das können wir dann wiederum genauso anwenden wie auch bei gleichverteiltem Rauschen

## Was haben wir nun gelernt?
Wir haben offensichtlich gelernt, wie wir mit den Signalen umgehen können.
Aber viel wichtiger ist das, was ich nicht erklärt habe, aber was wir alle zwangsweise gemacht haben. Wir haben nämlich gelernt ein Problem in einzelne Teile zu zerlegen, die man einzeln angehen kann. Und diese einzelnen Probleme möglichst gut mathematisch zu begründen, um sich daraus zu erklären, wie man gewisse Dinge lösen kann. 
Diese Art und Weise auf die Veränderungen der Stage einzugehen kann man immer wieder anwenden und sollte man sich immer beibehalten.

Ich hoffe es war ein wenig Lesenswertes dabei, und das der Artikel interessant war, und wünsche weiter viel Erfolg beim Wettbewerb! :)

