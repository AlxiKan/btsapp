require "csv"
require "date"
require 'net/http'
require 'uri'

class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]
  before_action :authenticate_user! #, except: [:index, :show]
  before_action :correct_user, only: [:show, :edit, :update, :destroy]

  # GET /customers or /customers.json
  def index
    @customers = Customer.all
    
    # Show by ID
    if params[:customer_id].present?
      @customer = Customer.find_by(id: params[:customer_id])
      if @customer
        redirect_to customer_path(@customer)
      else
        flash[:notice] = "Customer not found"
        redirect_to customers_path
      end
    end

    # Show by Search
    if params[:column_name].present? && params[:column_value].present?
      if Customer.column_names.include?(params[:column_name])
        @customers = Customer.where(params[:column_name] => params[:column_value])
      else
        flash[:notice] = "Column #{params[:column_name]} doesn't exist"
        redirect_to customers_path
      end
    end

  end
  
  def correct_user
    @customer = current_user.customers.find_by(id: params[:id])
    redirect_to customers_path, notice: "Customer not found." if @customer.nil?
  end
  
  def customers_import
    if params[:file].present? && params[:user_id].present?
      if params[:file].content_type == "text/csv" && File.extname(params[:file].original_filename).downcase == ".csv"
        Customer.import(params[:file], params[:user_id])
        redirect_to customers_path, notice: "Customers imported successfully."
      else
        redirect_to customers_path, notice: "Please select a valid file format."
      end
    end
  end  

  def customer_call
    if params[:id].present? && params[:outcome].present?
      if params[:outcome] == "Not selected"
        redirect_to request.original_url, notice: "Please select an outcome."
      else
        Customer.call(params[:id], params[:outcome])
        redirect_to customers_path, notice: "Customer called"
      end
    end
  end

  def customers_reset
    if params[:user_id].present?
      Customer.reset(params[:user_id])
      redirect_to customers_path, notice: "Customers have been reset."
    end
  end

  def customers_delete
    if params[:user_id].present?
      Customer.where(user_id: params[:user_id]).delete_all
      redirect_to customers_path, notice: "Customers have been deleted."
    end
  end

  def customers_action
    if params[:user_id].present? && params[:action_type].present?
      uri = URI.parse("https://127.0.0.1:5000/#{params[:action_type]}")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      if params[:action_type] == "training/new"
        data = { data: JSON.parse(Customer.training(params[:user_id])) }.to_json
      elsif params[:action_type] == "prediction"
        data = { data: JSON.parse(Customer.prediction(params[:user_id])) }.to_json
      end 
      request.body = data
      request["Content-Type"] = "application/json"
      begin
        response = http.request(request)
        data = JSON.parse(response.body)
        if data["Error"]
          redirect_to customers_path, notice: "#{data}"
        else
          redirect_to customers_path
        end
      rescue StandardError => e
        redirect_to customers_path, notice: "API Services not available."
      end
    end
  end

  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    # @customer = Customer.new
    @customer = current_user.customers.build
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    # @customer = Customer.new(customer_params)
    @customer = current_user.customers.build(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_url, notice: "Customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:first_name, :last_name, :email, :contact, :prediction, :outcome, :date_of_birth, :job, :marital, :education, :balance, :default, :housing, :loan, :calls, :last_call, :previous_calls, :previous_outcome, :user_id, :notes)
    end
end
