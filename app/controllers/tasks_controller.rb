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
    begin
      request_body = is_json_request? ? JSON.parse(request.body.read) : params
      descript = request_body["description"]
    rescue JSON::ParserError
      descript = ''
    end
    task = Task.new(user: current_user, description: descript)
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
    begin
      task = Task.find(params[:id])
      if is_json_request?
        if task.user == current_user
          json task
        else
          status 404
          json({})
        end
      else
        if task.user == current_user
          erb :"tasks/edit.html", locals: { task: task }
        else
          redirect '/tasks', error: 'Task not found'
        end
      end
    rescue ActiveRecord::RecordNotFound
      if is_json_request?
        status 404
        json({})
      else
        redirect '/tasks', error: 'Task not found'
      end
    end
  end

  put '/tasks/:id' do
    begin
      task = Task.find(params[:id])
      request_body = is_json_request? ? JSON.parse(request.body.read) : params
      task.description = request_body["description"]
      task.complete = request_body["complete"]
    rescue ActiveRecord::RecordNotFound
      if is_json_request?
        status 404
        return json({})
      else
        redirect '/tasks', error: 'Task not found'
        return
      end
    rescue JSON::ParserError
      task.description = ''
    end
      if is_json_request?
        if task.user == current_user
          if task.save
            status 200
            json task
          else
            status 400
            json errors: task.errors.full_messages
          end
        else
          status 404
          json({})
        end
      else
        if task.save && task.user == current_user
          redirect "/"
        else
          flash.now[:errors] = task.errors.full_messages.join("; ")
          erb :"tasks/edit.html", locals: { task: task }
        end
      end
  end

  delete '/tasks/:id' do
    begin
      task = Task.find(params[:id])
      if is_json_request?
        if task.user == current_user
          task.destroy!
          status 204
        else
          status 404
          json({})
        end
      else
        if task.user == current_user
          task.destroy!
          redirect "/"
        else
          redirect '/tasks', error: 'Task not found'
        end
      end
    rescue ActiveRecord::RecordNotFound
      if is_json_request?
        status 404
        json({})
      else
        redirect '/tasks', error: 'Task not found'
      end
    end
  end
end
