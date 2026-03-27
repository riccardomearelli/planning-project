
:- multifile 
    initially/2, 
    prim_action/1, 
    prim_fluent/1.



:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
    causes_true/3,
    causes_false/3,
    causes_val/4,
    poss/2.

% There is nothing to do caching on (required becase cache/1 is static)
cache(_) :- fail.

% --- TASK ---

task(browsing).
task(working).

% --- FLUENTI ---

prim_fluent(battery).
prim_fluent(temperature).
prim_fluent(remaining_hours(T)):-task(T).
prim_fluent(cost).

fun_fluent(battery).
fun_fluent(temperature).
fun_fluent(remaining_hours(T)):-task(T).
fun_fluent(cost).

% --- AZIONI ---

prim_action(tdp_low(T)) :- task(T).
prim_action(tdp_medium(T)) :- task(T).

prim_action(recharge).
prim_action(cooling).

% --- EFFETTI ---

causes_val(tdp_low(T), battery, B , B is battery - 10).
causes_val(tdp_low(T), temperature, Temp , Temp is temperature + 20).
causes_val(tdp_low(T),remaining_hours(T), H, H is remaining_hours(T)-1).
causes_val(tdp_low(T), cost, C is cost + 5 ).

causes_val(tdp_medium(T), battery, B , B is battery - 15).
causes_val(tdp_medium(T), temperature, Temp , Temp is temperature + 30).
causes_val(tdp_medium(T),remaining_hours(T), H, H is remaining_hours(T)-1).
causes_val(tdp_medium(T), cost, C is cost + 4 ).



causes_val(recharge, battery, 100, true).
causes_val(cooling, temperature, 0, true).

% --- PRECONDIZIONI ---

poss(tdp_low(T), (battery > 5, temperature < 80, remaining_hours(T)>0 )).
poss(tdp_medium(T), (battery > 5, temperature < 70, remaining_hours(T)>0 )).


poss(recharge, true).
poss(cooling, true).



% --- STATO INIZIALE ---
initially(battery, 100).
initially(temperature, 25).
initially(cost, 0).
initially(remaining_hours(browsing),3).
initially(remaining_hours(working),2).



% --- PROCEDURA ---


% 1. Punto di ingresso
proc(minimize_cost_task,
    search(try_budget(0))
).

% 2. Iterative Deepening sul costo
proc(try_budget(Max),
    ndet(
        % Ramo A: Tenta di completare i task. 
        % Il test finale ?(cost <= Max) valida se il piano trovato è economico.
        [control(complete_all_task), ?(cost <= Max)],
        
        % Ramo B: Se fallisce, aumenta il budget
        [?(Max < 100), pi(m, [?(m is Max + 1), try_budget(m)])]
    )
).

% 3. La procedura di controllo (SENZA search interno)
proc(control(complete_all_task),
    while(some(t, and(task(t), remaining_hours(t) > 0)), 
        pi(t, [
            ?(and(task(t), remaining_hours(t) > 0)),
            % Qui il non-determinismo permette al search esterno 
            % di provare combinazioni diverse per stare nel budget Max.
            ndet(
                tdp_medium(t), 
                ndet(
                    tdp_low(t),  
                    ndet(cooling, recharge)
                )       
            )
        ])
    )
).






