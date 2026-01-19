---
author: Paul (Phnt0m)
author_bio: >
    Physikstudent und Hobby-Programmierer
tags: ["Monte-Carlo", "Markov-Chain", "Signals", "Algorithmus"]
---

# Mit Zufall ans Ziel (aka Metropolis-Hastings-Algorithmus)


## Einleitung
Das Hauptproblem der aktuellen Stage _Dark Signal_ ist es, die Positionen der Gems zu bestimmen. Hierzu gibt es verschiedenste Ansätze. Ich habe mich für einen "naiven" Ansatz entschieden: Raten :)

Na gut, ganz so einfach ist es nicht. Grob zusammengefasst rate ich verschiedenste Edelstein-Positionen, bewerte sie und verbessere sie iterativ. Für einen einzelnen Edelstein im Maze ist das Leben einfach: Man kann einfach per Brute-Force alle Positionen testen und die Auswählen, die am besten zu den gemessenen Signalen passen. Bei einer map von 49x29 sind das 1421 Konfigurationen ("States") die man testen muss. Das geht schnell. Wenn man 2 Gems hat, können es dann schon 2.017.820, das war gerade so machbar ohne wilde Tricks. Bei 3 Gems hört der Spaß leider mit 2.863.286.580 States auf, in 100 ms wird das knapp. Was kann man also machen?

Mathematisch versuchen wir hier ein Inverses Problem zu Lösen (für Menschen die Mathe-Affine sind): Wir haben Messwerte vom einem einen skalaren Felds an verschiedenen Positionen gegeben und versuchen die Quellen (Gems) zu bestimmen. Mathematisch ist das leider nicht ganz trivial. Da ich meinen Bot in C programmiere, will ich ein keinen großen Solver basteln.

Vor nicht allzu langer Zeit habe ich ein Paper zum Thema Daten modellieren gelesen ([Paper](https://arxiv.org/abs/1008.4686), kann ich sehr empfehlen. Lösungen als ipynb gibt es hier: [Repo](https://github.com/wdconinc/data-analysis-recipes-fitting-a-model-to-data)) Fitten von Daten zu einem Modell ist ein sehr ähnliches Problem. Der Bot misst das Signal an verschiedenen Orten (unsere Messwerte) und will wissen wo die Gems liegen müssen (Modell). Wir wissen (zum Glück) welchen Effekt die Gems auf das Signal haben. Also versucht auch der Bot das Problem zu lösen, welches Modell die gemessenen Werte produziert. 

## Monte-Carlo
Der Metropolis-Hastings-Algorithmus versucht nun genau diese Modell zu bestimmen. Wir wissen, dass zu jedem Zeitpunkt 0-3 Gems im Maze vorhanden sind (0-1 sind trivial, entweder keine Gem oder wir finden ihn mit Brute-Force). Im Fall von zwei Gems können wir folgendes tun: Wir generieren zufällige States, hier zwei Gems die zufällige im Maze verteilt sind. 

Pro zufälligem State läuft es wie folgt ab: 
1. Wir bestimmen, wie gut der State zu dem Messwerten unseres Bots passen. Wir können einfach aus den Gem-Positionen das Signal am Bot berechnen und den
Fehler zu unseren Messwerten als Metrik verwenden. 

2. Dann mutieren wir den State, z.B. in dem wir einen der Gems leicht verschieben.  

3. Anschließend testen wir erneut, wie gut der leicht mutierte State zu den Messwerten passt. 

4. Ist der neue State besser als der alte nehmen wir ihn an. Ist er schlechter nehmen wir ihn *manchmal* an: Wenn die Fehlerdifferenz `Δe = e_neu - e_alt` ist, dann nehmen wir ihn mit einer Wahrscheinlichkeit von `P = exp(-Δe/T)` an. 

`T` ist dabei ein Parameter der Temperatur genannt wird (wahrscheinlich wegen Boltzmann-Gesetz). Je größer `T`, desto wahrscheinlicher wird der neue State angenommen, sodass der Parameterraum aggressiver abgesucht wird. Es ist wichtig, manchmal 'schlechtere' States zu besuchen, um nicht in lokalen Minima steckenzubleiben. Man kann sich das so vorstellen, das der State durch den Parameterraum läuft und das Optimum sucht. Einen solchen Prozess nennt man auch Markov Chain. Somit handelt es sich hier um eine Markov-Chain Monte-Carlo Methode.  

Dieses Prozedere machen wir nicht nur mit einem State, sondern mit vielen sogenannten *Walkern*. In der Regel: Je mehr States, desto genauer das Resultat. Außerdem, je länger die Kette an besuchten States, desto besser approximiert sie die tatsächliche Lösung. Dieses Ensemble an Walkern macht der Algorithmus sehr stabil gegen Fehler und lokale Minima.

Da das Signal kein Noise oder ähnliches hat können wir einfach am Ende den State mit dem geringsten Fehler als 'Wahrheit', also also bestes Modell für unsere Messwerte benutzen.

## Simulation
Hier eine kleine Visualisierung (braucht JavaScript):

<div style="color:#2ff; padding:15px; border:1px solid #333; max-width:600px; margin:auto; border-radius:8px; font-family: monospace; background:#111;">
    <div style="border-bottom:1px solid #333; padding-bottom:8px; margin-bottom:10px; font-size:12px; display:flex; justify-content:space-between;">
        <span>> ENSEMBLE_MCMC</span>
        <span style="color:#888;">Temp: <span id="tVal" style="color:#abf;">0.20</span></span>
    </div>
    <canvas id="tempCanvas" width="570" height="280" style="background:#000; width:100%; display:block; border:1px solid #222;"></canvas>
    <div style="margin-top:12px; background:#222; padding:10px; border-radius:5px;">
        <div style="display:flex; align-items:center; gap:15px; margin-bottom:10px;">
            <label style="font-size:11px; color:#aaa; white-space:nowrap;">ADJUST TEMP:</label>
            <input type="range" id="tempSlider" min="0.01" max="2.0" step="0.01" value="0.2" style="flex-grow:1; cursor:pointer; accent-color:#abf;">
        </div>
        <div style="display:flex; justify-content:space-between; align-items: center; font-size:11px;">
            <div>
                <span style="color:#2ff">■</span> Path | <span style="color:#55f">○</span> Ensemble
            </div>
            <div style="text-align:right; display:flex; align-items:center; gap:8px;">
                Best SSE: <span id="eVal" style="color:#2ff">0.00</span> 
                <button id="toggleBtn" onclick="toggleSim()" style="background:#2ff; color:#000; border:none; padding:3px 12px; cursor:pointer; border-radius:3px; font-weight:bold; min-width:60px;">START</button>
                <button onclick="resetSim()" style="background:#333; color:#2ff; border:1px solid #2ff; padding:2px 8px; cursor:pointer; border-radius:3px;">RESET</button>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    var canvas = document.getElementById('tempCanvas'), ctx = canvas.getContext('2d');
    var errOut = document.getElementById('eVal'), tOut = document.getElementById('tVal'), tSlider = document.getElementById('tempSlider');
    var toggleBtn = document.getElementById('toggleBtn');
    var trueGems, botHistory, ensemble;
    var isRunning = false; // Resource preservation flag
    const W = 570, H = 280, NUM_WALKERS = 100;

    function init() {
        trueGems = [
            {x: 350, y: Math.floor(50 + Math.random()*180)}, 
            {x: 150, y: Math.floor(50 + Math.random()*180)}
        ];
        
        botHistory = [];
        var sx = Math.floor(150 + Math.random()*50), sy = Math.floor(80 + Math.random()*100);
        for(var i=0; i<20; i++) {
            if (i < 7 || i > 15) sx += 6; else sy += 6;
            botHistory.push({x: sx, y: sy});
        }

        ensemble = [];
        for(var i=0; i<NUM_WALKERS; i++) {
            ensemble.push({
                g1: {x: Math.floor(Math.random()*W), y: Math.floor(Math.random()*H)},
                g2: {x: Math.floor(Math.random()*W), y: Math.floor(Math.random()*H)},
                error: Infinity
            });
        }
        draw(); // Initial draw while paused
    }

    function sig(g, p) {
        var d = Math.sqrt(Math.pow(g.x-p.x,2) + Math.pow(g.y-p.y,2));
        return 5000.0 / (d + 1.5);
    }

    function getSSE(s) {
        var err = 0.0;
        botHistory.forEach(p => {
            var a = sig(trueGems[0], p) + sig(trueGems[1], p);
            var g = sig(s.g1, p) + sig(s.g2, p);
            err += Math.pow(a - g, 2);
        });
        return err / botHistory.length;
    }

    function draw() {
        ctx.fillStyle = 'rgba(0,0,0,1)'; ctx.fillRect(0,0,W,H);
        ctx.fillStyle = '#2ff'; botHistory.forEach(p => ctx.fillRect(p.x-3, p.y-3, 6, 6));
        ctx.fillStyle = '#f44'; trueGems.forEach(g => { ctx.beginPath(); ctx.arc(g.x, g.y, 6, 0, 7); ctx.fill(); });
        ensemble.forEach(w => {
            ctx.strokeStyle = 'rgba(85, 85, 255, 0.4)';
            [w.g1, w.g2].forEach(g => { ctx.beginPath(); ctx.arc(g.x, g.y, 4, 0, 7); ctx.stroke(); });
        });
    }

    function loop() {
        if (!isRunning) return; // Stop the loop

        var bestE = Infinity;
        var currentTemp = parseFloat(tSlider.value);
        tOut.innerText = currentTemp.toFixed(2);

        ensemble.forEach(w => {
            for(var i=0; i<5; i++) {
                var eC = getSSE(w);
                var step = 25;
                var nS = {
                    g1: {x: Math.max(0, Math.min(W, Math.floor(w.g1.x + (Math.random()-0.5)*step))), 
                         y: Math.max(0, Math.min(H, Math.floor(w.g1.y + (Math.random()-0.5)*step)))},
                    g2: {x: Math.max(0, Math.min(W, Math.floor(w.g2.x + (Math.random()-0.5)*step))), 
                         y: Math.max(0, Math.min(H, Math.floor(w.g2.y + (Math.random()-0.5)*step)))}
                };
                var eN = getSSE(nS);
                if (eN < eC || Math.random() < Math.exp(-(eN - eC) / currentTemp)) {
                    w.g1 = nS.g1; w.g2 = nS.g2; w.error = eN;
                }
            }
            if (w.error < bestE) bestE = w.error;
        });

        errOut.innerText = bestE.toFixed(2);
        draw();
        requestAnimationFrame(loop);
    }

    window.toggleSim = function() {
        isRunning = !isRunning;
        toggleBtn.innerText = isRunning ? "STOP" : "START";
        toggleBtn.style.background = isRunning ? "#f44" : "#2ff";
        if (isRunning) loop();
    };

    window.resetSim = function() {
        init();
        errOut.innerText = "0.00";
    };

    init();
})();
</script>

## Fazit
Aktuell verwende ich 200 Walker mit jeweils 500 Iterationen pro möglicher Gem Zahl. Ich finde damit meist in 3-5 Messwerten/Moves die tatsächlichen Edelstein-Positionen. Klingt recht gut, keine Ahnung wie sich das mit anderen Methoden vergleicht. Mit ein paar Optimierungen und hab ich eine average response time des Bots von ca. 15 ms.
