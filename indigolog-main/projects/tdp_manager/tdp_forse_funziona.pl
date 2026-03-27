% =========================================================
% --- DIRETTIVE E CACHE ---
% =========================================================
:- multifile prim_action/1, prim_fluent/1, causes_val/4, poss/2, initially/2, proc/2.
:- multifile rel_fluent/1, fun_fluent/1, cache/1, actionNum/2.

% Cache obbligatoria
cache(battery). cache(temp). cache(total_cost).
cache(rem(T)) :- member(T, [work, browsing, movie, gaming]).

execute(A, success) :- prim_action(A). 

% --- DOMINI ---
task(work). 
task(browsing). 
task(movie). 
task(gaming).
mode(low). 
mode(medium). 
mode(high). 
mode(veryhigh).

% --- AZIONI ---
prim_action(do(M, T)) :- mode(M), task(T).
prim_action(recharge).
prim_action(cooling).

actionNum(do(M, T), Final) :- 
    atom_concat(do_, M, Prefix), Final =.. [Prefix, T].
actionNum(recharge, recharge).
actionNum(cooling, cooling).

% --- FLUENTI ---
fun_fluent(battery). 
fun_fluent(temp). 
fun_fluent(total_cost).
fun_fluent(rem(T)) :- task(T).

% --- STATO INIZIALE ---
initially(battery, 100).
initially(temp, 20).
initially(total_cost, 0).
initially(rem(work), 2).
initially(rem(browsing), 2).
initially(rem(movie), 1).
initially(rem(gaming), 1).

% --- LEGGI CAUSALI ---
causes_val(do(M, _), battery, B, B is battery - V) :- (M=low->V=5; M=medium->V=10; M=high->V=15; V=20).
causes_val(recharge, battery, 100, true).
causes_val(do(M, _), temp, T, T is temp + V) :- (M=low->V= -5; M=medium->V=10; M=high->V=20; V=30).
causes_val(cooling, temp, T, T is temp - 30).
causes_val(do(M, _), total_cost, C, C is total_cost + V) :- (M=low->V=4; M=medium->V=2; M=high->V=1; V=0).
causes_val(recharge, total_cost, C, C is total_cost + 6).
causes_val(cooling, total_cost, C, C is total_cost + 5).
causes_val(do(_, T), rem(T), N, N is rem(T) - 1).

% --- PRECONDIZIONI ---
poss(do(M, T), and(rem(T) > 0, and(battery >= 20, temp < 80))).
poss(recharge, battery < 100).
poss(cooling, temp > 30).

% =========================================================
% --- LOGICA DI CONTROLLO (STILE ASCENSORE) ---
% =========================================================

% Conta quanti task mancano
proc(count_tasks(N),
    ?(N is rem(work) + rem(browsing) + rem(movie) + rem(gaming))).

% La procedura ricorsiva che sceglie liberamente
proc(solve_all(MaxCost),
    ndet(
        [?(and(rem(work)=0, and(rem(browsing)=0, and(rem(movie)=0, rem(gaming)=0)))), ?(total_cost =< MaxCost)],
        [?(total_cost < MaxCost), 
         pi(t, pi(m, [?(task(t)), ?(mode(m)), do(m, t)])),
         solve_all(MaxCost)]
    )
).

% Iterative Deepening
proc(minimize_cost(C),
    ndet(
        solve_all(C),
        pi(next, [?(next is C + 1), ?(next < 40), minimize_cost(next)])
    )
).

% Procedura per stampare lo stato dei task
proc(print_report, [
    % Estraiamo i valori uno per uno usando il nome del fluente definito
    ?(rem(work) = W), 
    ?(rem(browsing) = B), 
    ?(rem(gaming) = G), 
    ?(rem(movie) = M),
    ?(total_cost = C),
    
    [?(write('--- REPORT STATO FINALE ---')), ?(nl)],
    [?(write('Gaming rimasti:  ')), ?(write(G)), ?(nl)],
    [?(write('Browsing rimasti: ')), ?(write(B)), ?(nl)],
    [?(write('Movie rimasti:    ')), ?(write(M)), ?(nl)],
    [?(write('Work rimasti:     ')), ?(write(W)), ?(nl)],
    [?(write('--------------------------')), ?(nl)],
    [?(write('COSTO TOTALE EFFETTIVO: ')), ?(write(C)), ?(nl)]
]).

% Modifica il controller per includere il report
proc(control(smart), [
    search(minimize_cost(0)), 
    print_report
]).