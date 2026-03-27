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
    and(temp >= 70,
        hour =< 16)).

poss(recharge,
    (and(battery < 30
    and(temp =< 90,
        hour =< 15)))).

poss(turn_off,
    and(
        battery >= 0,
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
initially(temp,60).
initially(battery,100).
initially(totalCost,0).

initially(scheduled(browsing), 2).
initially(scheduled(working), 0).
initially(scheduled(entertainment), 0).
initially(scheduled(gaming), 7).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPTIMIZED IDA* CONTROLLER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(handle_ida(Bound),
    ndet(
        % GOAL
        [ ?(and(scheduled(browsing)=0,
                and(scheduled(working)=0,
                and(scheduled(entertainment)=0,
                    scheduled(gaming)=0)))),
          turn_off
        ],

        % EXPANSION
        [
          % COST BOUND
          ?( totalCost =< Bound ),

          % SELECT ONLY VALID TASKS (reduces branching a lot)
          ?(task(K)),
          ?(scheduled(K) > 0),

          % ACTIONS (ordered: cheapest useful first, 0-cost last)
          ndet(
            % HIGH (cost 1) → best practical default
            [ do_high(K), handle_ida(Bound) ],

            ndet(
              % MEDIUM (cost 2)
              [ do_medium(K), handle_ida(Bound) ],

              ndet(
                % LOW (cost 4)
                [ do_low(K), handle_ida(Bound) ],

                ndet(
                  % VERYHIGH (cost 0) → RESTRICTED
                  [ ?(scheduled(K) > 1),
                    do_veryhigh(K),
                    handle_ida(Bound)
                  ],

                  ndet(
                    % COOLING
                    [ ?(temp >= 100),
                      cooling,
                      handle_ida(Bound)
                    ],

                    % RECHARGE
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
        % SMART BOUND INCREASE
        pi(n,
        ndet(
            [ ?(n is Bound + 1), ida(n) ],
            ndet(
            [ ?(n is Bound + 2), ida(n) ],
            ndet(
                [ ?(n is Bound + 4), ida(n) ],
                ndet(
                [ ?(n is Bound + 5), ida(n) ],
                [ ?(n is Bound + 6), ida(n) ]
                )
            )
            )
        )
        )
    )
).

proc(control(ida),
    search(ida(20))
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMB CONTROLLER (FOR COMPARISON)
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
      turn_off
    ]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTION MAPPING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

actionNum(X, X).