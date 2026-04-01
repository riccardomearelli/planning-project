:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
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
fun_fluent(totalCost).
fun_fluent(scheduled(_)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prim_action(do_low(_)).
prim_action(do_medium(_)).
prim_action(do_high(_)).
prim_action(do_veryhigh(_)).
prim_action(cooling).
prim_action(recharge).
prim_action(turn_off).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRECONDITIONS
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
    and(temp >= 100,
        hour =< 16)).

poss(recharge,
    and(temp =< 90,
        and(battery =< 15,
        hour =< 15))).

poss(turn_off,
    and(
        battery >= 5,
        and(hour =< 16,
        and(scheduled(browsing) = 0,
        and(scheduled(working) = 0,
        and(scheduled(entertainment) = 0,
            scheduled(gaming) = 0)))))
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EFFECTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- DO LOW ----
causes_val(do_low(K), hour, H2, H2 is hour + 1).
causes_val(do_low(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_low(K), battery, B2, B2 is battery - 5).
causes_val(do_low(K), temp, T2, T2 is temp - 10).
causes_val(do_low(K), totalCost, C2, C2 is totalCost + 4).

% ---- DO MEDIUM ----
causes_val(do_medium(K), hour, H2, H2 is hour + 1).
causes_val(do_medium(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_medium(K), battery, B2, B2 is battery - 10).
causes_val(do_medium(K), temp, T2, T2 is temp + 10).
causes_val(do_medium(K), totalCost, C2, C2 is totalCost + 3).

% ---- DO HIGH ----
causes_val(do_high(K), hour, H2, H2 is hour + 1).
causes_val(do_high(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_high(K), battery, B2, B2 is battery - 15).
causes_val(do_high(K), temp, T2, T2 is temp + 10).
causes_val(do_high(K), totalCost, C2, C2 is totalCost + 2).

% ---- DO VERY HIGH ----
causes_val(do_veryhigh(K), hour, H2, H2 is hour + 1).
causes_val(do_veryhigh(K), scheduled(K), S2, S2 is scheduled(K) - 1).
causes_val(do_veryhigh(K), battery, B2, B2 is battery - 20).
causes_val(do_veryhigh(K), temp, T2, T2 is temp + 20).
causes_val(do_veryhigh(K), totalCost, C2, C2 is totalCost + 1).

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
% ABBREVIATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(goal, and(scheduled(browsing)=0,
                and(scheduled(working)=0,
                and(scheduled(entertainment)=0,
                and(scheduled(gaming)=0,
                and(battery >= 5,
                    temp =< 95)))))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initially(hour,1).
initially(temp,20).
initially(battery,100).
initially(totalCost,0).

initially(scheduled(browsing), 7).
initially(scheduled(working), 2).
initially(scheduled(entertainment), 2).
initially(scheduled(gaming), 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRINT REPORT HELPER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(print_report, [
    ?(battery = B), 
    ?(temp = T),
    ?(totalCost = C),
    ?(hour = H),
    
    [?(write('-------- FINAL  REPORT --------')), ?(nl)],
    [?(write('Remaining battery:       ')), ?(write(B)), ?(nl)],
    [?(write('Temperature level: ')), ?(write(T)), ?(nl)],
    [?(write('Current hour: ')), ?(write(H)), ?(nl)],
    [?(write('-------------------------------')), ?(nl)],
    [?(write('TOTAL COST:                    ')), ?(write(C)), ?(nl)]
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDA* CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(handle_ida(Bound),
    ndet(
        % GOAL
        [ ?(goal),
          turn_off
        ],

        % EXPANSION
        [
          % COST AND HOUR BOUND
          ?( hour =< 16 ),
          ?( totalCost =< Bound ),

          % SELECT VALID TASKS
          ?(task(K)),
          ?(scheduled(K) > 0),

          % ACTIONS
          ndet(
            % HIGH (cost 2)
            [ do_high(K), handle_ida(Bound) ],

            ndet(
              % MEDIUM (cost 3)
              [ do_medium(K), handle_ida(Bound) ],

              ndet(
                % LOW (cost 4)
                [ do_low(K), handle_ida(Bound) ],

                ndet(
                  % VERYHIGH (cost 1)
                  [ do_veryhigh(K), handle_ida(Bound) ],

                  ndet(
                    % COOLING (cost 5)
                    [ ?(temp >= 100),
                      cooling,
                      handle_ida(Bound)
                    ],

                    % RECHARGE (cost 6)
                    [ ?(battery =< 15),
                      recharge,
                      handle_ida(Bound)
                    ]
                  )
                )
              )
            )
          )
        ]
    )
).

proc(ida(Bound),
    ndet(
        handle_ida(Bound),

        % BOUND INCREASE
        pi(n, [ ?(n is Bound + 1), ida(n) ])
    )
).

proc(control(ida),
    [search(ida(0)),
    print_report]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDERED IDA* SIMPLIFIED CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(handle_ida_ordered(Bound),
    ndet(
        % GOAL
        [ ?(goal),
          turn_off
        ],

        % EXPANSION
        pi(k,
          [
            % TASK PRIORITY ORDER ------ SIMPLIFICATION
            % WORKING -> ENTERTAINMENT -> BROWSING -> GAMING
            ndet(
              [ ?(scheduled(working) > 0),      ?(k = working)      ],
              ndet(
                [ ?(scheduled(entertainment) > 0), ?(k = entertainment) ],
                ndet(
                  [ ?(scheduled(browsing) > 0),    ?(k = browsing)    ],
                  [ ?(scheduled(gaming) > 0),      ?(k = gaming)      ]
                )
              )
            ),

            % ACTIONS
            ndet(
                % HIGH (cost 2)
                [ do_high(k), handle_ida_ordered(Bound) ],

                ndet(
                % MEDIUM (cost 3)
                [ do_medium(k), handle_ida_ordered(Bound) ],

                ndet(
                    % LOW (cost 4)
                    [ do_low(k), handle_ida_ordered(Bound) ],

                    ndet(
                    % VERYHIGH (cost 1)
                    [ do_veryhigh(k), handle_ida_ordered(Bound) ],

                    ndet(
                        % COOLING (cost 5)
                        [ ?(temp >= 100),
                            cooling,
                            handle_ida_ordered(Bound)
                        ],

                        % RECHARGE (cost 6)
                        [ ?(battery =< 15),
                            recharge,
                            handle_ida_ordered(Bound)
                        ]
                    )
                    )
                )
                )
            )
          ]
        )
    )
).

proc(ida_ordered(Bound),
    ndet(
        handle_ida_ordered(Bound),

        % BOUND INCREASE
        pi(n, [ ?(n is Bound + 1), ida(n) ])
    )
).

proc(control(ida_ordered),
    [search(ida_ordered(0)),
    print_report]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXOGENOUS ACTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exog_action(boil).
causes_val(boil, temp, 100, true).
exog_action(discharge).
causes_val(discharge, battery, B, B is battery - 10).
exog_action(idle).
causes_val(idle, hour, H, H is hour + 1).
exog_action(battery_swap).
causes_val(battery_swap, battery, 100, true).
exog_action(reset_stat).
causes_val(reset_stat, battery, 100, true).
causes_val(reset_stat, temp, 20, true).


prim_action(Act) :- exog_action(Act).
poss(Act, true) :- exog_action(Act).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDERED IDA* SIMPLIFIED REACTIVE CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(control(ida_ordered_reactive), [prioritized_interrupts(
        [
          interrupt(neg(goal), search(ida_ordered(0)))
        ]),
         print_report]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMB CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(control(dumb),
    [ while(
        or(scheduled(browsing) > 0,
        or(scheduled(working) > 0,
        or(scheduled(entertainment) > 0,
           scheduled(gaming) > 0))),
        ndet(
            pi(k, do_veryhigh(k)),
            ndet(
                pi(k, do_high(k)),
                ndet(
                    pi(k, do_medium(k)),
                    ndet(
                        pi(k, do_low(k)),
                        ndet(
                            cooling,
                            recharge
                        )
                    )
                )
            )
        )),
      turn_off,
      print_report
    ]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION MAPPING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

actionNum(X, X).