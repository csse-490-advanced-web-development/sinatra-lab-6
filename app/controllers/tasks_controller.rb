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
    task = Task.new(description: params[:description], user: current_user)

    if task.save
      if is_json_request?
        status 201
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
        erb :"tasks/new.html"
      end
    end
  end

  get '/tasks/:id' do
    task = Task.find_by_id(params[:id])

    if task.nil? or task.user != current_user
      status 404
      if is_json_request?
        halt json({})
      end
      halt
    end

    if is_json_request?
      json task
    else
      erb :"tasks/edit.html", locals: { task: task }
    end
  end

  put '/tasks/:id' do
    task = Task.find_by_id(params[:id])

    if task.nil? or task.user != current_user
      status 404
      if is_json_request?
        halt json({})
      end
      halt
    end

    task.description = params[:description]
    task.complete = params[:complete]

    if task.save
      if is_json_request?
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
  end

  delete '/tasks/:id' do
    task = Task.find_by_id(params[:id])

    if task.nil? or task.user != current_user
      status 404
      if is_json_request?
        halt json({})
      end
      halt
    end

    task.destroy!

    if is_json_request?
      status 204
    else
      redirect "/"
    end
  end
end
