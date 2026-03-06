(define (domain tdp_domain)

(:requirements :equality :typing :strips :action-costs) ;strips?

(:types hour task battery tdp - object)

(:predicates
    (current ?h - hour)
    (next ?h1 - hour ?h2 - hour)

    (scheduled ?h - hour ?t - task)

    (battery-level ?b - battery)
    (battery-next ?b1 - battery ?b2 - battery) ; transition relation

    ; (requires-medium ?t - task)
    ; (requires-high ?t - task)

    ; (tdp-low ?l - tdp)
    ; (tdp-medium ?l - tdp)
    ; (tdp-high ?l - tdp)
    ; (tdp-veryhigh ?l - tdp)
    ; Performance rewards
    ; | Task          | Low | Medium | High | Very High |
    ; | ------------- | --- | ------ | ---- | --------- |
    ; | Browsing      | 1   | 2      | 3    | 4         |
    ; | Working       | -   | 4      | 6    | 7         |
    ; | Entertainment | -   | 3      | 5    | 7         |
    ; | Gaming        | -   | -      | 6    | 9         |
    ;
    ; Penalties for perfomance
    ; | Task          | Low | Medium | High | Very High |
    ; | ------------- | --- | ------ | ---- | --------- |
    ; | Browsing      | 3   | 2      | 1    | 0         |
    ; | Working       | -   | 3      | 1    | 0         |
    ; | Entertainment | -   | 4      | 2    | 0         |
    ; | Gaming        | -   | -      | 3    | 0         |
)

(:functions
    (total-cost)
)

(:action do-low-browsing
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h browsing)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    ; (not (requires-medium ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b2)

    (increase (total-cost)  3)
 )
)

(:action do-medium-browsing
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h browsing)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b3)

    (increase (total-cost) 2)
 )
)

(:action do-medium-working
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h working)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b3)

    (increase (total-cost) 3)
 )
)

(:action do-medium-entertainment
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h entertainment)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b3)

    (increase (total-cost) 4)
 )
)

(:action do-high-browsing
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h browsing)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 1)
 )
)

(:action do-high-working
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h working)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 1)
 )
)

(:action do-high-entertainment
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h entertainment)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 2)
 )
)

(:action do-high-gaming
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h gaming)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b4)

    (increase (total-cost) 3)
 )
)

(:action do-veryhigh-browsing
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h browsing)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b5)

    (increase (total-cost) 0)
 )
)

(:action do-veryhigh-working
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h working)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b5)

    (increase (total-cost) 0)
 )
)

(:action do-veryhigh-entertainment
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h entertainment)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
    ; (not (requires-high ?t))
 )
 :effect (and
    (not (current ?h))
    (current ?h2)

    (not (battery-level ?b1))
    (battery-level ?b5)

    (increase (total-cost) 0)
 )
)

(:action do-veryhigh-gaming
;  :parameters (?h ?h2 - hour ?t - task ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :parameters (?h ?h2 - hour ?b1 ?b2 ?b3 ?b4 ?b5 - battery)
 :precondition (and
    (current ?h)
    (next ?h ?h2)
    (scheduled ?h gaming)
    (battery-level ?b1)
    (battery-next ?b1 ?b2)
    (battery-next ?b2 ?b3)
    (battery-next ?b3 ?b4)
    (battery-next ?b4 ?b5)
    ; (not (requires-high ?t))
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