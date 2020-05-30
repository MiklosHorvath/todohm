#!/bin/bash
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

wait_for_enter(){
	echo -e "${PURPLE}PRESS ENTER${NO_COLOR} to $1"
	read -r -s -p ''
}

init_testing_todo_app(){
	start_mvn_project
	wait_for_enter 'continue when maven project started'
	upload_test_data
}

start_mvn_project(){
	echo "Starting maven project"
	mvn install
	xfce4-terminal -e 'mvn exec:java -Dexec.mainClass=com.codecool.todohm.TodohmApplication'
}

upload_test_data(){
	echo "startig adding test todos"
	for nameIndex in {1..5}
	do
   		curl -X POST http://localhost:8080/addTodo?todo-title=valami$nameIndex
	done
	echo "finished adding test todos. list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_toggle_completed_by_id(){
	wait_for_enter 'test endpoint: PUT http://localhost:8080/todos/2/toggle_status?status=true'
	echo "starting to change status of todo with id=2"
	curl -X PUT http://localhost:8080/todos/2/toggle_status?status=true
	echo "finished to change status of todo with id=2. list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_delete_completed(){
	wait_for_enter 'test endpoint: DELETE  http://localhost:8080/todos/completed'
	echo "starting to delete completed todos"
	curl -X DELETE  http://localhost:8080/todos/completed 
	echo "finished delete. list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_toggle_all_to_completed(){
	wait_for_enter 'test endpoint: PUT http://localhost:8080/todos/toggle_all?toggle-all=true'
	echo "starting to set all todo to completed"
	curl -X PUT http://localhost:8080/todos/toggle_all?toggle-all=true
	echo "finnished to set all todos to completed. list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_delete_todo_by_id(){
	wait_for_enter 'test endpoint: DELETE http://localhost:8080/todos/3'
	echo "staring to delete todo with id=3"
	curl -X DELETE http://localhost:8080/todos/3
	echo "finished delete todo with id=3 list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_update_title_by_id(){
	wait_for_enter 'test endpoint: PUT http://localhost:8080/todos/4?todo-title=newtitlefortest'
	echo "starting update name for todo with id 4 to newtitlefortest"
	curl -X PUT http://localhost:8080/todos/4?todo-title=newtitlefortest
	echo "finished update  name for todo with id 4 to newtitlefortest list of todos are:"
	curl -X POST  http://localhost:8080/list | json_pp
}

test_get_title_by_id(){
	wait_for_enter 'test endpoint: GET http://localhost:8080/todos/4'
	echo 'start retrieveing name for todo with id 4'
	curl http://localhost:8080/todos/4
	echo ''
	
}

echo "Starting testing endpoints"
init_testing_todo_app
test_toggle_completed_by_id
test_delete_completed
test_toggle_all_to_completed
test_delete_todo_by_id
test_update_title_by_id
test_get_title_by_id
echo -e "${PURPLE}Testing ended${NO_COLOR}"
