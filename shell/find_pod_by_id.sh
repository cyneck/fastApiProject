docker ps -q | xargs docker inspect --format '{{.Id}},{{.Name}},{{.Name}}.{{.GraphDriver.Data.WorkDir}}' | grep $1
