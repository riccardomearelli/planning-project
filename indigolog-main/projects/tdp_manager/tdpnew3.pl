:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
    causes_val/4,
    causes_true/3,
    causes_false/3.

cache(_) :- fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

task(browsing).
task(working).
task(entertainment).
task(gaming).

requires_medium(working).
requires_medium(entertainment).
requires_high(gaming).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLUENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun_fluent(hour).
fun_fluent(temp).
fun_fluent(battery).
fun_fluent(scheduled(K)) :- task(K).
fun_fluent(totalCost).

% Boolean “ready” fluents for numeric constraints
rel_fluent(can_do_low(K)) :- task(K).
rel_fluent(can_do_medium(K)) :- task(K).
rel_fluent(can_do_high(K)) :- task(K).
rel_fluent(can_do_veryhigh(K)) :- task(K).
rel_fluent(can_cool).
rel_fluent(can_recharge).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prim_action(do_low(K)) :- task(K).
prim_action(do_medium(K)) :- task(K).
prim_action(do_high(K)) :- task(K).
prim_action(do_veryhigh(K)) :- task(K).
prim_action(cooling).
prim_action(recharge).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRECONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(do_low(K), can_do_low(K)).
poss(do_medium(K), can_do_medium(K)).
poss(do_high(K), can_do_high(K)).
poss(do_veryhigh(K), can_do_veryhigh(K)).
poss(cooling, can_cool).
poss(recharge, can_recharge).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EFFECTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- DO LOW ----
causes_val(do_low(K), hour, H2, H2 is hour + 1).
causes_val(do_low(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_low(K), battery, B2, B2 is battery - 5).
causes_val(do_low(K), temp, T2, if(temp >= 30, T2 is temp - 10, T2 is temp)).
causes_val(do_low(K), totalCost, C2, C2 is totalCost + 4).

% ---- DO MEDIUM ----
causes_val(do_medium(K), hour, H2, H2 is hour + 1).
causes_val(do_medium(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_medium(K), battery, B2, B2 is battery - 10).
causes_val(do_medium(K), temp, T2, T2 is temp + 10).
causes_val(do_medium(K), totalCost, C2, C2 is totalCost + 2).

% ---- DO HIGH ----
causes_val(do_high(K), hour, H2, H2 is hour + 1).
causes_val(do_high(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_high(K), battery, B2, B2 is battery - 15).
causes_val(do_high(K), temp, T2, T2 is temp + 10).
causes_val(do_high(K), totalCost, C2, C2 is totalCost + 1).

% ---- DO VERY HIGH ----
causes_val(do_veryhigh(K), hour, H2, H2 is hour + 1).
causes_val(do_veryhigh(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_veryhigh(K), battery, B2, B2 is battery - 20).
causes_val(do_veryhigh(K), temp, T2, T2 is temp + 20).
causes_val(do_veryhigh(K), totalCost, C2, C2 is totalCost + 0).

% ---- COOLING ----
causes_val(cooling, hour, H2, H2 is hour + 1).
causes_val(cooling, temp, T2, T2 is temp - 30).
causes_val(cooling, totalCost, C2, C2 is totalCost + 5).

% ---- RECHARGE ----
causes_val(recharge, hour, H2, H2 is hour + 2).
causes_val(recharge, battery, 100, true).
causes_val(recharge, temp, T2, T2 is temp + 10).
causes_val(recharge, totalCost, C2, C2 is totalCost + 6).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BOOLEAN FLUENT UPDATES (for numeric constraints)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

causes_true(do_low(K), can_do_low(K), false) :- task(K).
causes_true(do_medium(K), can_do_medium(K), false) :- task(K).
causes_true(do_high(K), can_do_high(K), false) :- task(K).
causes_true(do_veryhigh(K), can_do_veryhigh(K), false) :- task(K).
causes_true(cooling, can_cool, false).
causes_true(recharge, can_recharge, false).

% Boolean “ready” evaluation rules
proc(update_ready_fluents,
    [pi(K, [
        ?(battery >= 5, set(can_do_low(K))),
        ?(battery >= 10, set(can_do_medium(K))),
        ?(battery >= 15, temp =< 90, set(can_do_high(K))),
        ?(battery >= 20, temp =< 80, set(can_do_veryhigh(K)))
    ]),
     ?(temp >= 100, set(can_cool)),
     ?(battery =< 90, set(can_recharge))
    ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initially(hour,1).
initially(temp,40).
initially(battery,60).
initially(totalCost,0).
initially(scheduled(browsing), 2).
initially(scheduled(working), 3).
initially(scheduled(entertainment), 2).
initially(scheduled(gaming), 5).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(goal_all_tasks_done,
    ?(and(
        scheduled(browsing) = 0,
        scheduled(working) = 0,
        scheduled(entertainment) = 0,
        scheduled(gaming) = 0
    ))
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIMAL CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(control(optimal),
    [update_ready_fluents,
     search(minimize(totalCost), goal_all_tasks_done)
    ]).