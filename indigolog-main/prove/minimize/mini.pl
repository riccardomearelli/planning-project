:- dynamic controller/1.
:- discontiguous fun_fluent/1, rel_fluent/1, proc/2, causes_true/3, causes_val/4, poss/2.
:- multifile initially/2, prim_action/1, connected/3, cache/1.
cache(_) :- fail. 

% --- MAPPA ---
connected(a, c, 20).
connected(c, d, 5).
connected(a, b, 10).
connected(b, d, 30).

% --- AZIONI ---
prim_action(move(From, To)) :- connected(From, To, _).
prim_action(deliver).

% --- FLUENTI ---
prim_fluent(robot_at).
fun_fluent(robot_at).
rel_fluent(delivered).

% --- REGOLE CAUSALI ---
causes_val(move(_From, To), robot_at, To, true).
causes_true(deliver, delivered, true).

% --- PRECONDIZIONI ---
poss(move(From, To), and(robot_at = From, some(cost, connected(From, To, cost)))).
poss(deliver, robot_at = d).

% --- STATO INIZIALE ---
initially(robot_at, a).
initially(delivered, false).

% --- LOGICA DI RICERCA ---

% search: fa lookahead completo

proc(mini,
    search(try_budget(0))
).

% try_budget(Max) — iterative deepening sul costo
% ndet tenta **prima il Ramo A**, e solo se fallisce passa al Ramo B. Quindi la sequenza è:
% try_budget(0)  → handle_reqs(0)  → fallisce (nessun arco costa 0)
% try_budget(1)  → handle_reqs(1)  → fallisce
% try_budget(25) → handle_reqs(25) → SUCCESSO con a→c→d
% (non prova mai try_budget(26))

proc(try_budget(Max),
    ndet(
        handle_reqs(Max), % Ramo A: prova a risolvere con budget Max
        [?(Max < 50), pi(m, [?(m is Max + 1), try_budget(m)])] % Ramo A: prova a risolvere con budget Max
    )
).


% handle_reqs(Max) — navigazione con budget rimanente **,
% ndet(
%  Ramo 1,   % sono già adiacente a d?
%  Ramo 2    % muoviti verso un nodo intermedio
%)


proc(handle_reqs(Max),
    ndet(
        % Ramo 1: passo diretto verso d
        pi(cost, [
            ?(and(connected(robot_at, d, cost), Max >= cost)),
            move(robot_at, d),
            deliver
        ]),
        % Ramo 2: passo intermedio (escludi d)
        pi(dest, pi(cost, [
            ?(and(connected(robot_at, dest, cost), and(dest \= d, Max >= cost))),
            move(robot_at, dest),
            pi(rem, [?(rem is Max - cost), handle_reqs(rem)])
        ]))
    )
).