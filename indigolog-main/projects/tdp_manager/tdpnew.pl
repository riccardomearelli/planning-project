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
% PRECONDITION AXIOMS (FORMULA STYLE)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poss(do_low(K),
    and(task(K),
    and(neg(requires_medium(K)),
    and(neg(requires_high(K)),
    and(battery >= 5,
    and(scheduled(K) > 0,
        hour =< 16)))))).

poss(do_medium(K),
    and(task(K),
    and(neg(requires_high(K)),
    and(battery >= 10,
    and(temp =< 90,
    and(scheduled(K) > 0,
        hour =< 16)))))).

poss(do_high(K),
    and(task(K),
    and(battery >= 15,
    and(temp =< 90,
    and(scheduled(K) > 0,
        hour =< 16))))).

poss(do_veryhigh(K),
    and(task(K),
    and(battery >= 20,
    and(temp =< 80,
    and(scheduled(K) > 0,
        hour =< 16))))).

poss(cooling,
    and(temp = 100,
        hour =< 16)).

poss(recharge,
    and(temp =< 90,
        hour =< 15)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EFFECT AXIOMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- DO LOW ----
causes_val(do_low(K), hour, H2, H2 is hour + 1).
causes_val(do_low(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_low(K), battery, B2, B2 is battery - 5).

causes_val(do_low(K), temp, T2,
    if(temp >= 30, T2 is temp - 10, T2 is temp)).

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
% GOAL: ALL TASKS DONE
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
    search(minimize(totalCost),
        goal_all_tasks_done
    )
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SMART CONTROLLER WITH COST MINIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(some_task_pending,
    ?(scheduled(browsing) > 0;
      scheduled(working) > 0;
      scheduled(entertainment) > 0;
      scheduled(gaming) > 0)
).

proc(do_any_pending_task,
    pi(K,
       ?(scheduled(K) > 0) ->
           ndet(do_low(K),
                do_medium(K),
                do_high(K),
                do_veryhigh(K),
                cooling,
                recharge)
    )
).

proc(control(optimal),
    search(minimize(totalCost),
        while(some_task_pending,
            do_any_pending_task
        )
    )
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FULL CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%