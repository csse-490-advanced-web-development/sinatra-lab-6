require_relative "../spec_helper"

describe TasksController do
  describe "GET /tasks" do
    describe "when logged out" do
      before do
        get "/tasks", "", { "CONTENT_TYPE" => "application/json" }
      end

      it "returns unauthorized" do
        last_response.status.should == 401
      end
    end

    describe "logged in with todo items" do
      let(:user){ Fabricate(:user, email: 'samantha@example.com') }
      let!(:task1){ Fabricate(:task, description: 'Eat breakfast', user: user) }
      let!(:task2){ Fabricate(:task, description: 'Join class session', user: user) }
      let!(:task3){ Fabricate(:task, description: 'Work on lab', user: user, complete: true) }
      let!(:task4){ Fabricate(:task, description: 'This is someone else\'s todo!!', user: Fabricate(:user)) }
      before do
        direct_login_as(user)
        get "/tasks", {}, { "CONTENT_TYPE" => "application/json" }
      end

      it "should return the todo items as json" do
        json_response = JSON.parse(last_response.body)
        json_response.should == [
            { 'id' => task1.id, "description" => 'Eat breakfast', "complete" => false },
            { 'id' => task2.id, "description" => 'Join class session', "complete" => false },
            { 'id' => task3.id, "description" => 'Work on lab', "complete" => true }
        ]
      end
    end
  end

  describe "POST /tasks" do
    describe "when logged out" do
      before do
        post "/tasks", "", { "CONTENT_TYPE" => "application/json" }
      end

      it "returns unauthorized" do
        last_response.status.should == 401
      end
    end

    describe "with valid data" do
      before do
        direct_login_as(Fabricate(:user))
        post "/tasks", {description: 'Create a JSON API'}.to_json, { "CONTENT_TYPE" => "application/json" }
      end

      it "returns success" do
        last_response.status.should == 201
      end

      it "should return the new task" do
        json_response = JSON.parse(last_response.body)
        json_response["description"].should == "Create a JSON API"
        json_response["complete"].should == false
      end
    end

    describe "with invalid data" do
      before do
        direct_login_as(Fabricate(:user))
        post "/tasks", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns failure" do
        last_response.status.should == 400
      end

      it "should return the errors" do
        json_response = JSON.parse(last_response.body)
        json_response["errors"].should == ["Description can't be blank"]
      end
    end
  end

  describe "GET /tasks/:id" do
    describe "when logged out" do
      before do
        get "/tasks/1234", "", { "CONTENT_TYPE" => "application/json" }
      end

      it "returns unauthorized" do
        last_response.status.should == 401
      end
    end

    describe "a nonexistant task" do
      before do
        direct_login_as(Fabricate(:user))
        get "/tasks/1234", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end
    end

    describe "someone else's task" do
      before do
        direct_login_as(Fabricate(:user))
        task = Fabricate(:task)
        get "/tasks/#{task.id}", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end
    end

    describe "your own task" do
      let(:user){ Fabricate(:user) }
      let(:task){ Fabricate(:task, description: "Eat Breakfast", user: user) }
      before do
        direct_login_as(user)
        get "/tasks/#{task.id}", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns success" do
        last_response.status.should == 200
      end

      it "returns the task" do
        json_response = JSON.parse(last_response.body)
        json_response.should == { 'id' => task.id, "description" => 'Eat Breakfast', "complete" => false }
      end
    end
  end

  describe "PUT /tasks/:id" do
    describe "when logged out" do
      before do
        put "/tasks/12345", { description: 'Step 3: Profit' }.to_json, { "CONTENT_TYPE" => "application/json" }
      end

      it "returns unauthorized" do
        last_response.status.should == 401
      end
    end

    describe "your own task" do
      let(:user){ Fabricate(:user) }
      let(:task){ Fabricate(:task, description: "Create a JSON API", complete: false, user: user) }
      before do
        direct_login_as(user)
      end

      describe "with valid data" do
        before do
          put "/tasks/#{task.id}", { description: 'Step 3: Profit', complete: "true" }.to_json, { "CONTENT_TYPE" => "application/json" }
        end

        it "returns success" do
          last_response.status.should == 200
        end

        it "should return the updated task" do
          json_response = JSON.parse(last_response.body)
          json_response["description"].should == 'Step 3: Profit'
          json_response["complete"].should == true
        end

        it "should update that task" do
          task.reload
          task.description.should == 'Step 3: Profit'
          task.complete.should == true
        end
      end

      describe "your own task with invalid data" do
        before do
          put "/tasks/#{task.id}", { description: '' }.to_json, { "CONTENT_TYPE" => "application/json" }
        end

        it "returns failure" do
          last_response.status.should == 400
        end

        it "should return the errors" do
          json_response = JSON.parse(last_response.body)
          json_response["errors"].should == ["Description can't be blank"]
        end
      end
    end

    describe "updating a nonexistant task" do
      before do
        direct_login_as(Fabricate(:user))
        put "/tasks/1234", { description: "Does this even exist?" }.to_json, { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end
    end

    describe "someone else's task" do
      let(:someone_elses_task){ Fabricate(:task, description: "Finish homework") }
      before do
        direct_login_as(Fabricate(:user))
        put "/tasks/#{someone_elses_task.id}", { description: "Some users be evil" }.to_json, { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end

      it "does not update the task" do
        someone_elses_task.reload
        someone_elses_task.description.should == "Finish homework"
      end
    end
  end

  describe "DELETE /tasks/:id" do
    describe "when logged out" do
      before do
        delete "/tasks/1234", "", { "CONTENT_TYPE" => "application/json" }
      end

      it "returns unauthorized" do
        last_response.status.should == 401
      end
    end

      describe "a nonexistant task" do
      before do
        direct_login_as(Fabricate(:user))
        delete "/tasks/1234", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end
    end

    describe "someone else's task" do
      before do
        direct_login_as(Fabricate(:user))
        task = Fabricate(:task)
        delete "/tasks/#{task.id}", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns not found" do
        last_response.status.should == 404
      end

      it "returns an empty json body" do
        json_response = JSON.parse(last_response.body)
        json_response.should be_empty
      end
    end

    describe "your own task" do
      let(:user){ Fabricate(:user) }
      let(:task){ Fabricate(:task, description: "Eat Breakfast", user: user) }
      before do
        direct_login_as(user)
        delete "/tasks/#{task.id}", '', { "CONTENT_TYPE" => "application/json" }
      end

      it "returns success" do
        last_response.status.should == 204
      end

      it "returns an empty body" do
        last_response.body.should be_empty
      end

      it "deletes the task" do
        user.tasks.count.should == 0
      end
    end
  end
end
