class TasksController < ApplicationController
  get '/tasks' do
    tasks = current_user.tasks.all
    if is_json_request?
      json tasks.map { |task| {id: task.id, description: task.description, complete: task.complete} }
    else
      erb :"tasks/index.html", locals: { tasks: tasks }
    end
  end

  get '/tasks/new' do
    erb :"tasks/new.html"
  end

  post '/tasks' do
    task = current_user.tasks.new(description: params[:description], user: current_user)
    if task.save
      if is_json_request? 
        status 201
        json id: task.id, description: task.description, complete: task.complete
      else
        redirect "/"
      end
    else
      if is_json_request? 
        status 400
        json errors: task.errors.full_messages
      else
        flash.now[:errors] = task.errors.full_messages.join("; ")
        erb :"tasks/new.html"
      end
    end
  end
  

  get '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if task
      if is_json_request? 
        json id: task.id, description: task.description, complete: task.complete
      else
        erb :"tasks/edit.html", locals: { task: task }
      end
    else
      status 404
      json({})
    end
  end


  put '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if task
      task.description = params[:description]
      task.complete = params[:complete] == 'true'
      if is_json_request?
        if task.save
          status 200
          json id: task.id, description: task.description, complete: task.complete
        else
          status 400
          json errors: task.errors.full_messages
        end
      else 
        if task.save
          redirect "/"
        else
          flash.now[:errors] = task.errors.full_messages.join("; ")
          erb :"tasks/edit.html", locals: { task: task }
        end
      end
    else
      status 404
      json({})
    end
  end

  delete '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if task
      if is_json_request?
        task.destroy
        status 204 # No Content
        json({})
      else 
        task.destroy
        redirect "/"
      end
    else
      if is_json_request?
        status 404 # Not Found
        json({})
      else 
        redirect "/"
      end
    end
    
  end

end
