% =========================================================
% --- DIRETTIVE ---
% =========================================================
:- multifile prim_action/1, prim_fluent/1, causes_val/4, poss/2, initially/2, proc/2.
:- multifile rel_fluent/1, fun_fluent/1, cache/1, actionNum/2.

% --- CACHE ---
cache(battery). cache(temp). cache(total_cost).
cache(rem_work). cache(rem_browsing). cache(rem_gaming). cache(rem_movie).

execute(A, success) :- prim_action(A). 

% --- AZIONI ---
prim_action(do_low(T))      :- member(T, [work, browsing, movie, gaming]).
prim_action(do_medium(T))   :- member(T, [work, browsing, movie, gaming]).
prim_action(do_high(T))     :- member(T, [work, browsing, movie, gaming]).
prim_action(do_veryhigh(T)) :- member(T, [work, browsing, movie, gaming]).
prim_action(recharge).
prim_action(cooling).

actionNum(do_low(T),      do_low(T)).
actionNum(do_medium(T),   do_medium(T)).
actionNum(do_high(T),     do_high(T)).
actionNum(do_veryhigh(T), do_veryhigh(T)).
actionNum(recharge,       recharge).
actionNum(cooling,        cooling).

% --- FLUENTI ---
prim_fluent(battery). prim_fluent(temp). prim_fluent(total_cost).
prim_fluent(rem_work). prim_fluent(rem_browsing). prim_fluent(rem_gaming). prim_fluent(rem_movie).

fun_fluent(battery). fun_fluent(temp). fun_fluent(total_cost).
fun_fluent(rem_work). fun_fluent(rem_browsing). fun_fluent(rem_gaming). fun_fluent(rem_movie).

% =========================================================
% --- STATO INIZIALE (SCRITTURA ESPLICITA) ---
% =========================================================
initially(battery, 100).
initially(temp, 20).
initially(total_cost, 0).
initially(rem_work, 1).
initially(rem_browsing, 1).
initially(rem_gaming, 1).
initially(rem_movie, 1).

% =========================================================
% --- LEGGI CAUSALI ---
% =========================================================
causes_val(do_low(_),      battery, B, B is battery - 5).
causes_val(do_medium(_),   battery, B, B is battery - 10).
causes_val(do_high(_),     battery, B, B is battery - 15).
causes_val(do_veryhigh(_), battery, B, B is battery - 20).
causes_val(recharge,       battery, 100, true).

causes_val(do_medium(_),   temp, T, T is temp + 10).
causes_val(do_high(_),     temp, T, T is temp + 20).
causes_val(do_veryhigh(_), temp, T, T is temp + 30).
causes_val(cooling,        temp, T, T is temp - 30).
causes_val(recharge,       temp, T, T is temp + 10).

causes_val(do_low(_),      total_cost, C, C is total_cost + 4).
causes_val(do_medium(_),   total_cost, C, C is total_cost + 2).
causes_val(do_high(_),     total_cost, C, C is total_cost + 1).
causes_val(do_veryhigh(_), total_cost, C, C is total_cost + 0).

causes_val(do_low(work),      rem_work, N, N is rem_work - 1).
causes_val(do_medium(work),   rem_work, N, N is rem_work - 1).
causes_val(do_high(work),     rem_work, N, N is rem_work - 1).
causes_val(do_veryhigh(work), rem_work, N, N is rem_work - 1).

causes_val(do_low(browsing),      rem_browsing, N, N is rem_browsing - 1).
causes_val(do_medium(browsing),   rem_browsing, N, N is rem_browsing - 1).
causes_val(do_high(browsing),     rem_browsing, N, N is rem_browsing - 1).
causes_val(do_veryhigh(browsing), rem_browsing, N, N is rem_browsing - 1).

causes_val(do_high(movie),     rem_movie, N, N is rem_movie - 1).
causes_val(do_veryhigh(movie), rem_movie, N, N is rem_movie - 1).
causes_val(do_veryhigh(gaming), rem_gaming, N, N is rem_gaming - 1).

% =========================================================
% --- PRECONDIZIONI (CORRETTE) ---
% =========================================================

poss(do_low(work), and(battery >= 5, rem_work > 0)).
poss(do_low(browsing), and(battery >= 5, rem_browsing > 0)).
poss(do_medium(work), and(battery >= 10, rem_work > 0)).
poss(do_medium(browsing), and(battery >= 10, rem_browsing > 0)).
poss(do_high(movie), and(battery >= 15, rem_movie > 0)).
poss(do_veryhigh(gaming), and(battery >= 30, and(temp < 80, rem_gaming > 0))).
poss(recharge, battery < 100).
poss(cooling,  temp > 30).

% =========================================================
% --- LOGICA DI CONTROLLO ---
% =========================================================

proc(goal_done, 
    and(rem_work = 0, 
    and(rem_browsing = 0, 
    and(rem_gaming = 0, rem_movie = 0)))).

% Usiamo IF-THEN-ELSE annidati. È la sintassi più robusta in assoluto.

proc(smart_step,
    if(rem_gaming > 0, 
        do_veryhigh(gaming),
    if(rem_movie > 0, 
        do_high(movie),
    if(rem_work > 0, 
        do_medium(work),
    if(rem_browsing > 0, 
        do_low(browsing),
    recharge))) )
).

proc(control(smart), 
    while(neg(goal_done), smart_step)
).