:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
    causes_true/3,
    causes_false/3.

% There is nothing to do caching on (required becase cache/1 is static)
cache(_) :- fail.

  /*  FLUENTS and CAUSAL LAWS */
fun_fluent(hour).          % current hour
causes_val(do_low(_), hour, N, N is hour + 1).
causes_val(do_medium(_), hour, N, N is hour + 1).
causes_val(do_high(_), hour, N, N is hour + 1).
causes_val(do_veryhigh(_), hour, N, N is hour + 1).
causes_val(cooling, hour, N, N is hour + 1).
causes_val(recharge, hour, N, N is hour + 2).

fun_fluent(temp).          % temperature
causes_val(do_low(_), temp, N, N is temp + 5).
causes_val(do_medium(_), temp, N, N is temp + 10).
causes_val(do_high(_), temp, N, N is temp + 15).
causes_val(do_veryhigh(_), temp, N, N is temp + 20).
causes_val(cooling, temp, 40, true).

fun_fluent(battery).       % battery level
causes_val(do_low(_), battery, N, N is battery - 5).
causes_val(do_medium(_), battery, N, N is battery - 10).
causes_val(do_high(_), battery, N, N is battery - 15).
causes_val(do_veryhigh(_), battery, N, N is battery - 20).
causes_val(recharge, battery, 100, true).

fun_fluent(totalCost).     % accumulated cost
causes_val(do_low(_), totalCost, N, N is totalCost + 4).
causes_val(do_medium(_), totalCost, N, N is totalCost + 2).
causes_val(do_high(_), totalCost, N, N is totalCost + 1).
causes_val(do_veryhigh(_), totalCost, N, N is totalCost + 0).
causes_val(cooling, totalCost, N, N is totalCost + 5).
causes_val(recharge, totalCost, N, N is totalCost + 6).

rel_fluent(done(T)).       % task finished
causes_true(do_low(T), done(T), true).
causes_true(do_medium(T), done(T), true).
causes_true(do_high(T), done(T), true).
causes_true(do_veryhigh(T), done(T), true).

fun_fluent(remaining(T)).
causes_val(do_low(T), remaining(T), N, N is remaining(T) - 1).

requires_medium(working).
requires_medium(entertainment).
requires_high(gaming).
task(browsing).
task(working).
task(entertainment).
task(gaming).

  /*  ACTIONS and PRECONDITIONS*/
prim_action(do_low(T)) :- task(T).
poss(do_low(T),
     and(battery >= 5,
         neg(requires_medium(T)),
         neg(requires_high(T)),
         neg(done(T)))).

prim_action(do_medium(T)) :- task(T).
poss(do_medium(T),
     and(battery >= 10,
         neg(requires_high(T)),
         neg(done(T)))).

prim_action(do_high(T)) :- task(T).
poss(do_high(T),
     and(battery >= 15,
         neg(done(T)))).

prim_action(do_veryhigh(T)) :- task(T).
poss(do_veryhigh(T),
     and(battery >= 20,
         neg(done(T)))).

prim_action(cooling).
poss(cooling, temp >= 80).

prim_action(recharge).
poss(recharge, battery =< 20).

  /* ABBREVIATIONS */
proc(overheated, temp >= 90).
proc(low_battery, battery =< 15).
proc(task_pending(T), remaining(T) > 0).
proc(some_task_pending, some(t, task_pending(t))).

  /* EXOGENOUS ACTIONS */
exog_action(background_heat).
causes_val(background_heat, temp, N, N is temp + 3).

exog_action(power_drain).
causes_val(power_drain, battery, N, N is battery - 2).

prim_action(Act) :- exog_action(Act).
poss(Act, true) :- exog_action(Act).

  /* INITIAL STATE */
initially(hour,1).
initially(temp,40).
initially(battery,60).
initially(totalCost,0).
initially(done(browsing), false).
initially(done(working), false).
initially(done(entertainment), false).
initially(done(gaming), false).



  /*  Definitions of complex actions */
proc(execute_task(T),
    ndet(
        do_veryhigh(T),
        do_high(T),
        do_medium(T),
        do_low(T)
    )).

proc(serve_task,
    pi(t, [?(task_pending(t)), execute_task(t)])).

  /* CONTROLLERS */

proc(control(dumb),
    while(some_task_pending, serve_task)).

proc(control(planning),
     search(serve_task)).

  /* REACTIVE CONTROLLER: */

proc(control(tdp),
  [prioritized_interrupts(
    [ interrupt(overheated, cooling),
      interrupt(low_battery, recharge),
      interrupt(some_task_pending, serve_task),
      interrupt(true, ?(wait_exog_action))
    ])
  ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  INFORMATION FOR THE EXECUTOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Translations of domain actions to real actions (one-to-one)
actionNum(X, X).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%