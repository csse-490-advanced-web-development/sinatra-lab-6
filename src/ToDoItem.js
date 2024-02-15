import axios from 'axios'
import { useState } from "react";
import { useMutation } from 'react-query';
import { ajaxHeaders } from './AjaxHeaders';
import './ToDoItem.css';

const doDeleteTodo = (id, invalidateAndRefetch) => {
  axios({ method: 'DELETE',
          url: `/tasks/${id}`,
          data: {},
          headers: ajaxHeaders() })
  .finally(() => invalidateAndRefetch());
}

export const doSaveTodo = (id, description, complete, invalidateAndRefetch, setErrors, setMode) => {
  let data = { description: description, complete: complete.toString() }
  let method, path;

  if(id) {
    console.log(`Sending an API request to update task ${id} with the description ${description} and complete ${complete}`)
    method = 'PUT'
    path = `/tasks/${id}`
  } else {
    console.log(`Sending an API request to create the task ${description} and complete ${complete}`)
    method = 'POST'
    path = `/tasks`

  }
  axios({ method: method,
          url: path,
          data: data,
          headers: ajaxHeaders() })
  .then(() => {
    invalidateAndRefetch()
    setMode('view')
  }).catch((error) => {
    setErrors(error.response.data.errors)
  })
}

export function ToDoItem({item, invalidateAndRefetch}) {
  const [description, setDescription] = useState(item.description);
  const [complete, setComplete] = useState(!!item.complete);
  const [mode, setMode] = useState('view');
  const [errors, setErrors] = useState([]);
  const saveTodoMutation  = useMutation({
    mutationFn: (data) => doSaveTodo(...data, invalidateAndRefetch, setErrors, setMode)
  })

  const addTodo = (event) => {
    console.log("Showing new empty todo in the list")
    setMode('edit')
    event.preventDefault()
  }

  const toggleCheck = () => {
    console.log("Toggling the check!")
    let newState = !complete
    setComplete(newState)
    saveTodoMutation.mutateAsync([item.id, description, newState])
  }

  const deleteTodo = (event) => {
    event.preventDefault();
    if (item.id === '') {
      setMode('view')
    } else {
      doDeleteTodo(item.id, invalidateAndRefetch)
    }
  }

  const discardChange = (event) => {
    setMode('view')
    setDescription(item.description)
    event.preventDefault()
  }

  const editTodo = (event) => {
    setMode('edit')
    event.preventDefault()
  }

  const handleChange = (event) => {
    setDescription(event.target.value)
    setErrors([])
  }

  const saveChange = (event) => {
    console.log("description at saveChange is: ", description)
    saveTodoMutation.mutateAsync([item.id, description, complete])
    event.preventDefault()
  }

  const saveChangeOnBlur = (event) => {
    console.log("description at saveChangeOnBlur is: ", description)
    if(event.relatedTarget && (event.relatedTarget.tagName === "INPUT" || event.relatedTarget.tagName === "A")) {
      return;
    }
    saveChange(event);
  }

  if (mode === 'view'){
      if (item.id === ''){
        return (
          <a href="/tasks/new" onClick={addTodo} className="button">Add task</a>
        )
      }
      return (
        <li className="ToDoItem">
            <input type="checkbox" defaultChecked={!!complete} onChange={toggleCheck} />
            <a href={"/tasks/" + item.id} onClick={editTodo}>
                {description}
            </a>
        </li>
    );
  } else {
    return (
        <li className="ToDoItem">
            <form onSubmit={saveChange}>
                <label htmlFor="description">Task Description</label>
                <ErrorMessages errors={errors} />
                <input name="description" id="description" autoFocus type="text" value={description} onChange={handleChange} onBlur={saveChangeOnBlur} />
                <input type="submit" className="button" value={saveTodoMutation.isLoading ? 'Saving...' : 'Save'} disabled={saveTodoMutation.isLoading}/>
                <input type="submit" className="button" onClick={deleteTodo} value='Delete' disabled={saveTodoMutation.isLoading} />
                <a href="/tasks" onClick={discardChange}>cancel</a>
            </form>
        </li>
   );
  }
}

function ErrorMessages({errors}) {
  if(errors && errors.length > 0){
    return (
      <span class="errors" style={{color: 'red'}}>
        { errors }
      </span>
    )
  } else {
    return ''
  }
}

export default ToDoItem;
