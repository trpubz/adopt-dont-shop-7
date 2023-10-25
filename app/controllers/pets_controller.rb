class PetsController < ApplicationController
  def index
    @pets = if params[:search].present?
      Pet.search(params[:search])
    else
      Pet.adoptable
    end
  end

  def show
    @pet = Pet.find(params[:id])
  end

  def new
    @shelter = Shelter.find(params[:shelter_id])
  end

  def create
    pet = Pet.new(pet_params)
    if pet.save
      redirect_to "/shelters/#{pet_params[:shelter_id]}/pets"
    else
      redirect_to "/shelters/#{pet_params[:shelter_id]}/pets/new"
      flash[:alert] = "Error: #{error_message(pet.errors)}"
    end
  end

  def edit
    @pet = Pet.find(params[:id])
  end

  def update
    pet = Pet.find(params[:id])
    if params[:approve] == "true" && params[:name].include?("Approved")
      # approve == true ==== adoptable == false
      pet.update(adoptable: !ActiveRecord::Type::Boolean.new.cast(params[:approve]), name: params[:name])
      pet.save
      redirect_to "/admin/applications/#{params[:app_id]}"
    elsif params[:approve] == "false" && params[:name].include?("Rejected")
      pet.update(adoptable: ActiveRecord::Type::Boolean.new.cast(params[:approve]), name: params[:name])
      pet.save
      redirect_to "/admin/applications/#{params[:app_id]}"
    elsif pet.update(pet_params)
      redirect_to "/pets/#{pet.id}"
    else
      # require "byebug"; byebug
      redirect_to "/pets/#{pet.id}/edit"
      flash[:alert] = "Error: #{error_message(pet.errors)}"
    end
  end

  def destroy
    Pet.find(params[:id]).destroy
    redirect_to "/pets"
  end

  private

  def pet_params
    params.permit(:id, :name, :age, :breed, :adoptable, :shelter_id)
  end
end
