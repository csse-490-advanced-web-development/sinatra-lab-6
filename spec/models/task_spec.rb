require_relative "../spec_helper"

describe "Task" do
  describe "#create" do
    describe "with valid data" do
      before do
        Task.count.should eq 0  # Sanity check that we haven't got orphaned records hanging around
        Fabricate(:task, description: 'Eat breakfast')
      end

      it "should create a task" do
        Task.count.should be 1
      end

      it "should save the description we passed in" do
        Task.first.description.should eq "Eat breakfast"
      end
    end

    describe "without a description" do
      let(:task){ Task.new }
      before { task.save }

      it { task.should_not be_valid }
      it { task.errors[:description].should include "can't be blank" }
    end

    describe "with a blank description" do
      let(:task){ Task.new(description: "    ") }
      before { task.save }

      it { task.should_not be_valid }
      it { task.errors[:description].should include "can't be blank" }
    end

    describe "without a user" do
      let(:task){ Task.new }
      before { task.save }

      it { task.should_not be_valid }
      it { task.errors[:user].should include "can't be blank" }
    end
  end

  describe "#to_json" do
    let(:task){ Fabricate(:task, description: 'Eat breakfast', complete: true) }
    let(:task_json){ JSON.parse(task.to_json()) }

    it "does not include sensitive keys" do
      expected_keys = ['id', 'description', 'complete']
      expect(task_json.keys).to eq expected_keys
    end

    it { expect(task_json['id']).to eq task.id }
    it { expect(task_json['description']).to eq 'Eat breakfast' }
    it { expect(task_json['complete']).to eq true }
  end
end
