(define (problem tdp_problem) (:domain tdp_domain)
(:objects 
    b100 b95 b90 b85 b80 b75 b70 b65 b60 b55 b50 b45 b40 b35 b30 b25 b20 b15 b10 b05 b00 - battery
    browsing working entertainment gaming - task
    ; low medium high veryhigh - tdp
    h1 h2 h3 h4 h5 h6 h7 - hour ; one more than schedule (6h to begin with)
)

(:init
    (battery-next b100 b95)
    (battery-next b95 b90)
    (battery-next b90 b85)
    (battery-next b85 b80)
    (battery-next b80 b75)
    (battery-next b75 b70)
    (battery-next b70 b65)
    (battery-next b65 b60)
    (battery-next b60 b55)
    (battery-next b55 b50)
    (battery-next b50 b45)
    (battery-next b45 b40)
    (battery-next b40 b35)
    (battery-next b35 b30)
    (battery-next b30 b25)
    (battery-next b25 b20)
    (battery-next b20 b15)
    (battery-next b15 b10)
    (battery-next b10 b05)
    (battery-next b05 b00)
    (next h1 h2)
    (next h2 h3)
    (next h3 h4)
    (next h4 h5)
    (next h5 h6)
    (next h6 h7)
    ; (requires-medium working)
    ; (requires-medium entertainment)
    ; (requires-high gaming)
    ; Initial situation
    (scheduled h1 working)
    (scheduled h2 working)
    (scheduled h3 working)
    (scheduled h4 entertainment)
    (scheduled h5 gaming)
    (scheduled h6 browsing)
    (current h1)
    (battery-level b100)
    (= (total-cost) 0)
)

(:goal
  (and
     (current h7) ; for 6 hours schedule
     (not (battery-level b00))
  )
)

(:metric minimize (total-cost))

)
