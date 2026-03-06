# Create and use the container
## Requirements
- Docker

## Build docker container for the first time and run it
``` sh
docker-compose run --name planners --build planners
```

## Exit the container
``` sh
exit
```

## Start docker plan utils container
``` sh
docker start planners -i
```

## Find a solution
### A* with ff heuristic
``` sh
cd tdp_x
downward tdp_domain.pddl tdp_problem.pddl --search "astar(ff())"
```
### Weighted A*
``` sh
cd tdp_x
lama tdp_domain.pddl tdp_problem.pddl
```