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
    task = Task.new(user: current_user, description: params[:description])
    if task.save
      if is_json_request?
        status 201
        task.as_json.to_json
      else
        redirect "/"
      end
    else
      flash.now[:errors] = task.errors.full_messages.join("; ")
      erb :"tasks/new.html"
      status 400
      {errors: task.errors.full_messages}.to_json
    end
  end

  get '/tasks/:id' do
    task = Task.find(params[:id])
    erb :"tasks/edit.html", locals: { task: task }
  end

  put '/tasks/:id' do
    task = Task.find(params[:id])
    task.description = params[:description]
    if task.save
      redirect "/"
    else
      flash.now[:errors] = task.errors.full_messages.join("; ")
      erb :"tasks/edit.html", locals: { task: task }
    end
  end

  delete '/tasks/:id' do
    task = Task.find(params[:id])
    task.destroy!
    redirect "/"
  end
end
