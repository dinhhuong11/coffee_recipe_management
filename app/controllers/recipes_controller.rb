require 'securerandom'
class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    if !params[:search]
      @recipes = Recipe.all
    else
      @recipes = Recipe.where("name LIKE ?", "%"+params[:search]+"%")
      
    end
  end

  def show
    @recipe = Recipe.includes(:recipe_foods).find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = current_user.recipes.new(recipe_params)
    @recipe.file_path = save_file(params[:recipe][:image])
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to recipes_path, notice: 'Recipe was successfully created.' }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end
  def save_file(file)
    if file
      fileName = SecureRandom.uuid
      file_path = Rails.root.join('app/assets/images',fileName+file.original_filename)
      File.open(file_path, 'wb') do |f|
        f.write(file.read)
      end
      fileName+file.original_filename
    end
  end
  def edit
    
  end

  def update
    respond_to do |format|
      if params[:recipe][:image]
        @recipe.file_path = save_file(params[:recipe][:image])
      end
      
      if @recipe.update(recipe_params)
        format.html { redirect_to recipe_url(@recipe), notice: 'Recipe was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: 'Recipe was successfully destroyed.'
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :preparation_time, :cooking_time, :description, :public)
  end
end
