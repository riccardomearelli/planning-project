(define (domain tdp_domain)

(:requirements :equality :typing :strips :action-costs) ;strips?

(:types hour task battery tdp - object)

(:predicates
    (current ?h - hour)
    (next ?h1 - hour ?h2 - hour)

    (scheduled ?h - hour ?t - task)

    (battery-level ?b - battery)
    (battery-next ?b1 - battery ?b2 - battery) ; transition relation

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
 :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 - battery ?l)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h ?t)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (not (requires-medium ?t))
    (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b2)

    (increase (total-cost)  3)
 )
)

(:action do-medium
 :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h ?t)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b3)

    (increase (total-cost) 2)
 )
)

(:action do-high
 :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h ?t)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 1)
 )
)

(:action do-veryhigh
 :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h ?t)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b5)

    (increase (total-cost) 0)
 )
)

)