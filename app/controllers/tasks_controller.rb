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
	request_body = request.body.read
	if request_body != ''
	    json_data = JSON.parse(request_body)
	    description = json_data['description']
	else
	    description = ''
	end
	    task = Task.new(user: current_user, description: description)
	    if task.save
		status 201
		json task
	    else
		status 400
		json errors: task.errors.full_messages
	    end
    else
	task = Task.new(user: current_user, description: params[:description])
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
	    if task.user != current_user
		status 404
		halt(404, {}.to_json)
	     else
		status 200
	    	json task
	    end
	else
	    erb :"tasks/edit.html", locals: { task: task }
	end	
    rescue ActiveRecord::RecordNotFound
	halt(404, {}.to_json)
    end
  end
    
  put '/tasks/:id' do
    begin
    task = Task.find(params[:id])
    if task.user != current_user
	halt(404, {}.to_json)
    end

    if is_json_request?
	request_body = request.body.read
	if request_body != ''
	    json_data = JSON.parse(request_body)
	    description = json_data['description']
	    checked = json_data['complete']
	else
	    description = ''
	    checked = false
	end
	task.description = description
	task.complete = checked
    else
	task.description = params[:description]
    end
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

    rescue ActiveRecord::RecordNotFound
	halt(404, {}.to_json)
    end
  end

  delete '/tasks/:id' do
    begin
    task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
	halt(404, {}.to_json)
    end
    if task.user != current_user
	    halt(404, {}.to_json)
    end
    task.destroy!
    status 204
    if !is_json_request?
      redirect "/"
    end
  end

end
