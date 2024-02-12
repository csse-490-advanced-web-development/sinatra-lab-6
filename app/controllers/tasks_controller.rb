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
    task = Task.new(description: params[:description])

    if task.save
      redirect "/"
    else
      flash.now[:errors] = task.errors.full_messages.join("; ")
      erb :"tasks/new.html"
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
