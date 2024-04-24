require "csv"
require "date"

class Customer < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" } #, uniqueness: true
  validates :contact, presence: true #, format: { with: /\A\+30 (2\d{3} \d{6}|69\d \d{3} \d{4})\z/, message: "must be in the format '+30 2xxx xxxxxx' or '+30 69x xxx xxxx'" }
  # validations :prediction
  # validates :outcome, presence: true, exclusion: { in: ['not selected'], message: "'not selected' is not a valid outcome" }
  validates :date_of_birth, presence: true
  validates :balance, presence: true #, numericality: {"must be a number"}
  # validates :calls
  # validates :last_call
  validates :previous_calls, numericality: { greater_than_or_equal_to: 0, message: "must be a number greater than or equal to 0" }
  validates :job, inclusion: { in: %w(Managerial Technician Entrepreneur Blue-Collar Unknown Retired Administrative Services Self-Employed Unemployed Housemaid Student), message: "%{value} is not valid" }
  validates :marital, inclusion: { in: %w(Married Single Divorced Unknown), message: "%{value} is not valid" }
  validates :education, inclusion: { in: %w(Tertiary Secondary Unknown Primary), message: "%{value} is not valid" }
  validates :default, inclusion: { in: %w(No Yes), message: "%{value} is not valid" }
  validates :housing, inclusion: { in: %w(No Yes), message: "%{value} is not valid" }
  validates :loan, inclusion: { in: %w(No Yes), message: "%{value} is not valid" }
  validates :previous_outcome, inclusion: { in: %w(Unknown Failure Success), message: "%{value} is not valid" }
  
  def self.import(file, user_id)
      CSV.foreach(file.path, headers: true) do |row|
          customer_hash = row.to_hash
          customer_hash["user_id"] = user_id
          customer_hash["calls"] = 0
          customer_hash["previous_calls"] = 0
          customer_hash["last_call"] = Date.today
          customer_hash["prediction"] = "Unknown"
          customer_hash["outcome"] = "Unknown" 
          customer = Customer.new(customer_hash)
          customer.save
      end
  end

  def self.reset(user_id)
    customers = where(user_id: user_id)
    customers.update_all(outcome: "Unknown")
    customers.update_all(prediction: "Unknown")
    customers.update_all("previous_calls = previous_calls + calls")
    customers.update_all(calls: 0)
  end

  def self.call(customer_id, customer_outcome)
    customer = find(customer_id)
    customer.update(outcome: customer_outcome)
    customer.increment!(:calls)
    customer.update(last_call: Date.today, previous_outcome: customer.outcome)
    if (customer_outcome == "Success" && customer.prediction == "Positive") || (customer_outcome == "Failure" && customer.prediction == "Negative")
      customer.update(prediction: "Accurate")
    elsif customer.prediction == "Unknown"
      customer.update(prediction: "Not Predicted")
    else
      customer.update(prediction: "Inaccurate")
    end
  end

  def self.prediction(user_id)
    customers = where(user_id: user_id, prediction: "Unknown")
    customers = customers.select(
      :id,:contact,:last_call,:calls,
      :date_of_birth,:job,:marital,:education,:default,:balance,
      :housing,:loan,:previous_calls,:previous_outcome).to_json
    customers
  end

  def self.training(user_id)
    customers = where(user_id: user_id)
    customers = where.not(outcome: "Unknown")
    customers = customers.select(
      :contact,:calls,:date_of_birth,:job,:marital,:education,
      :default,:balance,:housing,:loan,:previous_calls,
      :previous_outcome,:outcome).to_json
    customers
  end
end





