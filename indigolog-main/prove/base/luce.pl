% Il Problema: Luce Automatica
% Vogliamo definire il comportamento di una luce che si accende solo se:
% Cè qualcuno nella stanza (presenza).
% La luce naturale è insufficiente (buio).

% Fluents descrivono ciò che può cambiare nel mondo. 
% In IndigoLog li definiamo come predicati che dipendono dal tempo o dalla situazione.
% accettata(luce): La lampada è accesa.
% presenza_rilevata: Cè una persona nella stanza.
% livello_luce(valore): Un valore numerico (es. da 0 a 100).

% Azioni Primitive
% Le azioni sono i "comandi" che modificano i fluenti.
% accendi: Porta accettata(luce) a vero.
% spegni: Porta accettata(luce) a falso.
% rileva_movimento: Cambia lo stato di presenza_rilevata.

% ============================================================================================

:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
    causes_true/3,
    causes_false/3.

% There is nothing to do caching on (required becase cache/1 is static)
cache(_) :- fail.


% ---FLUENTS:---

% prim_fluent(X): Dice al sistema "X è una variabile che cambia nel tempo".
% rel_fluent(X): Dice al sistema "X è un fluente di tipo Vero/Falso" (Relazionale).
% fun_fluent(X): Dice al sistema "X è un fluente che restituisce un Valore/Numero" (Funzionale).


prim_fluent(luce).
prim_fluent(presenza_rilevata).
prim_fluent(livello_luminosita).

% Fluenti Relazionali (Vero o Falso)
rel_fluent(luce).
rel_fluent(presenza_rilevata).

% Fluenti Funzionali (Valori numerici)
fun_fluent(livello_luminosita).


% ---AZIONI:---
prim_action(accendi).
prim_action(spegni).

% --- AZIONI ESOGENE ---
exog_action(entra).
exog_action(esce).

% --- MAPPATURA AZIONI (Necessaria per l Environment Manager) ---
% Assegna un numero intero a ogni azione definita

actionNum(accendi, 1).
actionNum(spegni, 2).
actionNum(entra, 3).  % La tua azione esogena
actionNum(esce, 4).



% ---EFFETTI:---
% Per i fluenti di tipo rel_fluent:
% causes_true(Azione, Fluente, Condizione):
% L azione rende il fluente Vero se la condizione è soddisfatta.

% causes_false(Azione, Fluente, Condizione):
% L azione rende il fluente Falso.

% Per i fun_fluent:
% causes_val(Azione, Fluente, NuovoValore, Condizione):
% Specifica esattamente quale valore assumerà il fluente dopo l azione.
% Qui N è il nuovo valore che il sensore o l utente ha deciso.


causes_true(accendi, luce, true).
causes_false(spegni, luce, true).

causes_val(accendi, livello_luminosita, 80, true).
causes_val(spegni, livello_luminosita, 1, true).

%---EFFETTI ESOGENI ---

causes_true(entra, presenza_rilevata, true).
causes_false(esce, presenza_rilevata, true).

% --- STATO INIZIALE ---
% Definiamo la situazione S0

initially(luce, false).
initially(presenza_rilevata, false).
initially(livello_luminosita, 30).

% ---PRECONDIZIONI:---
% poss (Precondizioni Fisiche): Indicano se l azione è eseguibile.
% Ad esempio, puoi premere "accendi" solo se la luce è spenta.
% poss(Azione, Condizione)

poss(accendi, neg(luce)).
poss(spegni, luce).

% proc o controllo (Logica di Decisione): È qui che decidi quando vuoi che il robot agisca 
% (se c è presenza o se è buio).

% Comando  | Sintassi             | IndiGolog | Descrizione
% Sequenza | "[azione1, azione2]" | Esegue le azioni in ordine.
% Test     | ?(condizione)        | Si ferma se la condizione non è vera in quel momento.
% Condizionale,"if(cond, prog1, prog2)","Se la condizione è vera esegue prog1, altrimenti prog2."
% Ciclo,"while(cond, prog)",Ripete prog finché la cond rimane vera.
% Scelta Non-Determ.,`(prog1,prog2)`
% Iterazione,star(prog),Esegue prog zero o più volte (non-deterministico).
% Uscita,exit,Termina la procedura con successo.

proc(logica_luce,[
    while(true,[
            % ACCENDI:
            if(and(neg(luce), or(presenza_rilevata, livello_luminosita<20)), [
            accendi
        ],  [
            % SPEGNI:
            if(and(luce, neg(presenza_rilevata)),[
            spegni
        ],  [
            ?(true)
                ])
            ])
        ])
    ]).


