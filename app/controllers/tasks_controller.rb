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
    if is_json_request?
      request.body.rewind
      body = request.body.read
      if !body.empty?
        request_body = JSON.parse(body)
        task = Task.new(description: request_body['description'], user: current_user)
        
        if task.save
          status 201
          body json(task)
        else
          status 400
          json 'errors' => task.errors.full_messages
        end
      else
        status 400
        json 'errors' => ["Description can't be blank"]
      end
    else
      task = Task.new(description: params[:description])

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
    if !is_json_request?
      erb :"tasks/edit.html", locals: { task: task }
    else
      if task
        json(task)
      else
        status 404
        body json("")
      end
    end
  end

  put '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if !task
      status 404
      json ""
    else
      task.description = params[:description]
      task.complete = params[:complete]
      if task.save
        if !is_json_request?
          redirect "/"
        else
          status 200
          json(task)
        end
      else
        if !is_json_request?
          flash.now[:errors] = task.errors.full_messages.join("; ")
          erb :"tasks/edit.html", locals: { task: task }
        else
          status 400
          json 'errors' => task.errors.full_messages
        end
      end
    end
  end

  delete '/tasks/:id' do
    task = current_user.tasks.find_by_id(params[:id])
    if task
      task.destroy!
      if is_json_request?
        status 204
      else
        redirect "/"
      end
    else
      if is_json_request?
        status 404
        json ""
      else
        redirect "/"
      end
    end
  end
end
