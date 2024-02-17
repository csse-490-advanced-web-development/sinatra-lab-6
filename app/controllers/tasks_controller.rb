class TasksController < ApplicationController
  get '/tasks' do
    tasks = current_user.tasks.all
    if is_json_request?
      json tasks
    else
      erb :"tasks/index.html", locals: { tasks: tasks }
    end
  end

  get '/tasks/new' do
    erb :"tasks/new.html"
  end

  post '/tasks' do
    task = current_user.tasks.new(description: params[:description])

    if is_json_request?
      if task.save
        status 201
        json task
      else
        status 400
        json errors: task.errors.full_messages
      end
    else
      if task.save
        redirect "/"
      else
        flash.now[:errors] = task.errors.full_messages.join("; ")
        erb :"tasks/new.html"
      end
    end
  end

  get '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if is_json_request?
      if task
        json task
      else
        status 404
        json({})
      end
    else 
      if task
        erb :"tasks/edit.html", locals: { task: task }
      else
        redirect '/'
      end
    end
  end

  put '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if task
      task.complete = params[:complete] == "true"
      task.description = params[:description]
      if task.save
        if is_json_request?
          status 200
          json task
        else
          redirect "/"
        end
      else 
        if is_json_request?
          status 400 
          json errors: task.errors.full_messages
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
    if is_json_request? 
      if task
        task.destroy
        status 204 
        json({})
      else
        status 404
        json({})
      end
    else 
      if task
        task.destroy
        redirect "/"
      else
        redirect "/"
      end
    end
  end
end
