(define (domain tdp_domain)

(:requirements :equality :typing :strips :action-costs :conditional-effects) ;strips?

(:types hour task battery temp - object)

(:predicates
    (current ?h - hour)
    (next ?h1 - hour ?h2 - hour)
    (prec ?h2 - hour ?h1 - hour)

    (scheduled ?t - task ?h - hour)

    (battery-level ?b - battery)
    (battery-next ?b1 - battery ?b2 - battery) ; transition relation

    (temp-level ?t - temp)
    (temp-next ?t1 ?t2 - temp)
    (temp-prec ?t2 ?t1 - temp)

    (requires-medium ?t - task)
    (requires-high ?t - task)

    ; (tdp-low ?l - tdp)
    ; (tdp-medium ?l - tdp)
    ; (tdp-high ?l - tdp)
    ; (tdp-veryhigh ?l - tdp)
    ;
    ; Penalties for perfomance
    ; | Task          | Low | Medium | High | Very High |
    ; | ------------- | --- | ------ | ---- | --------- |
    ; | Browsing      | 3   | 2      | 1    | 0         |
    ; | Working       | -   | 2      | 1    | 0         |
    ; | Entertainment | -   | 2      | 1    | 0         |
    ; | Gaming        | -   | -      | 1    | 0         |
)

(:functions
    (total-cost)
)

(:action do-low
 :parameters (?h ?h2 - hour ?t - task ?ht2 ?ht1 - hour ?b1 ?b2 - battery ?t1 ?t2 ?t3 - temp)
 :precondition (and
    (scheduled ?t ?ht2)
    (prec ?ht2 ?ht1)
    (current ?h)
    (next ?h ?h2)
    (battery-level ?b1)
    (temp-level ?t2)
    (temp-next ?t2 ?t3) ; da eliminare????
   ;  (temp-prec ?t2 ?t1)
    (battery-next ?b1 ?b2)
    (not (requires-medium ?t))
    (not (requires-high ?t))
 )
 :effect (and
    (not (scheduled ?t ?ht2))
    (scheduled ?t ?ht1)
    (not (current ?h))
    (current ?h2)
    (when (temp-prec ?t2 ?t1) (and (not (temp-level ?t2)) (temp-level ?t1)))

    (not (battery-level ?b1))
    (battery-level ?b2)

    (increase (total-cost)  4)
 )
)

(:action do-medium
 :parameters (?h ?h2 - hour ?t - task ?ht2 ?ht1 - hour ?b1 ?b2 ?b3 - battery ?t1 ?t2 - temp)
 :precondition (and
    (scheduled ?t ?ht2)
    (prec ?ht2 ?ht1)
    (current ?h)
    (next ?h ?h2)
    (temp-level ?t1)
    (temp-next ?t1 ?t2)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (not (requires-high ?t))
 )
 :effect (and
    (not (scheduled ?t ?ht2))
    (scheduled ?t ?ht1)
    (not (current ?h))
    (current ?h2)
    (not (temp-level ?t1))
    (temp-level ?t2)

    (not (battery-level ?b1))
    (battery-level ?b3)

    (increase (total-cost) 2)
 )
)

(:action do-high
 :parameters (?h ?h2 - hour ?t - task ?ht2 ?ht1 - hour ?b1 ?b2 ?b3 ?b4 - battery ?t1 ?t2 - temp)
 :precondition (and
    (scheduled ?t ?ht2)
    (prec ?ht2 ?ht1)
    (current ?h)
    (next ?h ?h2)
    (temp-level ?t1)
    (temp-next ?t1 ?t2)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
 )
 :effect (and
    (not (scheduled ?t ?ht2))
    (scheduled ?t ?ht1)
    (not (current ?h))
    (current ?h2)
    (not (temp-level ?t1))
    (temp-level ?t2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 1)
 )
)

(:action do-veryhigh
 :parameters (?h ?h2 - hour ?t - task ?ht2 ?ht1 - hour ?b1 ?b2 ?b3 ?b4 ?b5 - battery ?t1 ?t2 ?t3 - temp)
 :precondition (and
    (scheduled ?t ?ht2)
    (prec ?ht2 ?ht1)
    (current ?h)
    (next ?h ?h2)
    (temp-level ?t1)
    (temp-next ?t1 ?t2)
    (temp-next ?t2 ?t3)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
 )
 :effect (and
    (not (scheduled ?t ?ht2))
    (scheduled ?t ?ht1)
    (not (current ?h))
    (current ?h2)
    (not (temp-level ?t1))
    (temp-level ?t3)

    (not (battery-level ?b1))
    (battery-level ?b5)

    (increase (total-cost) 0)
 )
)

(:action cooling
    :parameters (?h1 ?h2 - hour ?t1 ?t2 ?t3 ?t4 ?t5 - temp)
    :precondition (and
      (current ?h1)
      (next ?h1 ?h2)
      (temp-level ?t4)
      (not (temp-next ?t4 ?t5))
      (temp-prec ?t4 ?t3)
      (temp-prec ?t3 ?t2)
      (temp-prec ?t2 ?t1)
    )
    :effect (and 
      (not (temp-level ?t4))
      (temp-level ?t1)
      (not (current ?h1))
      (current ?h2)

      (increase (total-cost) 5)
    )
)

(:action recharge
    :parameters (?h1 ?h2 ?h3 - hour ?t1 ?t2 - temp ?b - battery)
    :precondition (and
      (battery-level ?b)
      (current ?h1)
      (next ?h1 ?h2)
      (next ?h2 ?h3)
      (temp-level ?t1)
      (temp-next ?t1 ?t2)
    )
    :effect (and 
      (not (temp-level ?t1))
      (temp-level ?t2)
      (not (current ?h1))
      (current ?h3)
      (not (battery-level ?b))
      (battery-level b100)

      (increase (total-cost) 6)
    )
)


)