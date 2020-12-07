#!/bin/bash

function retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1

    until $cmd
    do
        if (( attempt_num == max_attempts ))
        then
            echo "cook.sh is not ready and there are no more attempts left!"
            exit 1
        else
            echo "cook.sh is not ready yet. Trying again in 10 seconds..."
            let attempt_num++
            sleep 10
        fi
    done
}

# Add nginx conf to proxy
if [ "$#" -ne 0 ] && [ ! -z "$1" ]; then
  echo "Configuring proxy..."
  docker exec proxy configure.sh $1
  docker exec proxy service nginx reload
fi

# hobo waits for db and rabbitmq so doesn't substitute env vars in /tmp.cook.sh.template
# immediatly
# We need -it for hobo to be verbose
retry 3 docker exec -it components deploy.sh $@
