require "pstore"
require_relative "../questionnaire"

RSpec.describe "Survey Program" do
  let(:store) { PStore.new("test.pstore") }

  before(:each) do
    # Clear out any existing data in the PStore for each test.
    store.transaction do
      store[:runs] = []
    end
  end

  describe "#normalize_answer" do
    it "returns 'Yes' for valid yes inputs" do
      expect(normalize_answer("Yes")).to eq("Yes")
      expect(normalize_answer("Y")).to eq("Yes")
      expect(normalize_answer("y")).to eq("Yes")
      expect(normalize_answer("yes")).to eq("Yes")
    end

    it "returns 'No' for valid no inputs" do
      expect(normalize_answer("No")).to eq("No")
      expect(normalize_answer("n")).to eq("No")
      expect(normalize_answer("N")).to eq("No")
      expect(normalize_answer("no")).to eq("No")
    end

    it "returns 'Invalid' for invalid inputs" do
      expect(normalize_answer("Maybe")).to eq("Invalid")
      expect(normalize_answer("")).to eq("Invalid")
      expect(normalize_answer("123")).to eq("Invalid")
    end
  end

  describe "#do_prompt" do
    it "prompts for questions and stores responses" do
      allow_any_instance_of(Object).to receive(:gets).and_return("Yes", "No", "Y", "N", "y")
      
      do_prompt(store)

      store.transaction(true) do
        last_run = store[:runs].last
        expect(last_run).to eq({
          "q1" => "Yes",
          "q2" => "No",
          "q3" => "Yes",
          "q4" => "No",
          "q5" => "Yes"
        })
      end
    end
  end

  describe "#calculate_run_score" do
    it "calculates score correctly based on answers" do
      run_data = {
        "q1" => "Yes",
        "q2" => "No",
        "q3" => "Yes",
        "q4" => "No",
        "q5" => "Yes"
      }

      score = calculate_run_score(run_data)
      expect(score).to eq(60.0)
    end
  end

  describe "#print_run_score" do
    it "prints the score for the most recent run" do
      allow_any_instance_of(Object).to receive(:puts)
      
      store.transaction do
        store[:runs] << { "q1" => "Yes", "q2" => "No", "q3" => "Yes", "q4" => "No", "q5" => "Yes" }
      end

      expect { print_run_score(store) }.to output(/Your score for this run: 60.0%/).to_stdout
    end
  end

  describe "#print_average_score" do
    it "calculates and prints the average score across runs" do
      allow_any_instance_of(Object).to receive(:puts)

      store.transaction do
        store[:runs] << { "q1" => "Yes", "q2" => "No", "q3" => "Yes", "q4" => "No", "q5" => "Yes" }  # 60.0%
        store[:runs] << { "q1" => "No", "q2" => "No", "q3" => "No", "q4" => "Yes", "q5" => "No" }   # 20.0%
      end

      expect { print_average_score(store) }.to output(/Average score across all runs: 40.0%/).to_stdout
    end
  end
end
