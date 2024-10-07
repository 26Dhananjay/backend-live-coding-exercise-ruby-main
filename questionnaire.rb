# require "pstore" # https://github.com/ruby/pstore

# STORE_NAME = "tendable.pstore"
# store = PStore.new(STORE_NAME)

# QUESTIONS = {
#   "q1" => "Can you code in Ruby?",
#   "q2" => "Can you code in JavaScript?",
#   "q3" => "Can you code in Swift?",
#   "q4" => "Can you code in Java?",
#   "q5" => "Can you code in C#?"
# }.freeze

# # TODO: FULLY IMPLEMENT
# def do_prompt
#   # Ask each question and get an answer from the user's input.
#   QUESTIONS.each_key do |question_key|
#     print QUESTIONS[question_key]
#     ans = gets.chomp
#   end
# end

# def do_report
#   # TODO: IMPLEMENT
# end

# do_prompt
# do_report

require "pstore" # https://github.com/ruby/pstore

STORE_NAME = "tendable.pstore"
store = PStore.new(STORE_NAME)

QUESTIONS = {
  "q1" => "Can you code in Ruby?",
  "q2" => "Can you code in JavaScript?",
  "q3" => "Can you code in Swift?",
  "q4" => "Can you code in Java?",
  "q5" => "Can you code in C#?"
}.freeze

def normalize_answer(answer)
  # Normalize input to "Yes" or "No"
  case answer.strip.downcase
  when "yes", "y"
    "Yes"
  when "no", "n"
    "No"
  else
    "Invalid" # If the input isn't valid
  end
end

# This method prompts the user for answers and stores them in PStore.
def do_prompt(store)
  responses = {}
  store.transaction do
    QUESTIONS.each_key do |question_key|
      answer = ""
      until %w[Yes No].include?(answer)
        print "#{QUESTIONS[question_key]} (Yes/No/Y/N): "
        answer = normalize_answer(gets.chomp)
        puts "Invalid input. Please answer Yes or No." if answer == "Invalid"
      end
      responses[question_key] = answer
    end
    store[:runs] ||= []
    store[:runs] << responses
  end
end

# This method calculates the score for a single run.
def calculate_run_score(run)
  yes_count = run.values.count("Yes")
  total_questions = QUESTIONS.size
  (100.0 * yes_count / total_questions).round(2)
end

# This method prints the score for the current run.
def print_run_score(store)
  store.transaction(true) do
    last_run = store[:runs].last
    score = calculate_run_score(last_run)
    puts "\nYour score for this run: #{score}%"
  end
end

# This method calculates and prints the average score across all runs.
def print_average_score(store)
  store.transaction(true) do
    all_runs = store[:runs]
    total_runs = all_runs.size
    total_score = all_runs.map { |run| calculate_run_score(run) }.sum
    average_score = (total_score / total_runs).round(2)
    puts "Average score across all runs: #{average_score}%"
  end
end

# Run the survey
do_prompt(store)
print_run_score(store)
print_average_score(store)
