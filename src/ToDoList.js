import axios from 'axios'
import { useQuery, useQueryClient } from 'react-query';
import { ajaxHeaders } from './AjaxHeaders';
import { ToDoItem } from './ToDoItem';
import './ToDoList.css';

function ToDoList() {
  const queryClient = useQueryClient();
  const { isPending, error, data, isFetching } = useQuery({
    queryKey: ['todos'],
    queryFn: () => axios({ method: 'get', url: '/tasks', data: {}, headers: ajaxHeaders() })
                    .then((response) => response.data)
                    .then((data) => { data.push({id: '', description: '', complete: false}); return data; })
  });
  let todos = data

  const invalidateAndRefetch = () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  }

  if(isPending || (isFetching && !data)) {
    return (
      <div className="container">
        <h1>If you can dream it, you can TODO it!</h1>
        <h3>Loading...</h3>
      </div>
    );
  }

  if (error) return 'An error has occurred: ' + error.message
  let incompleteTodos = todos.filter(todo => !todo.complete)
  let completeTodos = todos.filter(todo => todo.complete)
  return(
      <div className="container">
        <h1>If you can dream it, you can TODO it!</h1>
        <EmptyTodoListPrompt size={incompleteTodos.length} />
        <ul id="todos" className="ToDoList">
          {incompleteTodos.map( todo => (
            <ToDoItem key={todo.id} item={todo} invalidateAndRefetch={invalidateAndRefetch} />
          ))}
        </ul>

        <h2>You TODONE this:</h2>
        <ul id="completed_todos" className="ToDoList">
          {completeTodos.map( todo => (
              <ToDoItem key={todo.id} item={todo} invalidateAndRefetch={invalidateAndRefetch} />
          ))}
        </ul>
      </div>
  );
}

function EmptyTodoListPrompt({size}) {
  if(size > 1) {
    return null;
  } else {
    return (
      <p>There are no tasks remaining! You should add one!</p>
    )
  }
}

export default ToDoList;
