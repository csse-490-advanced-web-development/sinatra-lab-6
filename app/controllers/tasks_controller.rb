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
    task = Task.new( description: params[:description],user: current_user)
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
        {errors: task.errors.full_messages}.to_json
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
      task.as_json.to_json
      
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
      task.complete = params[:complete] =='true'
      if is_json_request?
        if task.save
          status 200
          task.as_json.to_json
        else
          status 400
          {errors: task.errors.full_messages}.to_json
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
    if is_json_request?
      if task == nil
        status 404
        json({})
      else
        status 204
        task.destroy!
      end
    else
      if task != nil
        task.destroy!
        redirect "/"
      end
    end
  end
end
