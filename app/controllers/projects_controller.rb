# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :set_tenant, except: :index
  before_action :verify_tenant

  def index
    @projects = Project.all
  end

  def show; end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to root_url, notice: 'Project was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to root_url, notice: 'Project was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :details, :expected_completion_date, :tenant_id)
  end

  def set_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  def verify_tenant
    return if params[:tenant_id] == Tenant.current_tenant_id.to_s

    redirect_to :root,
                flash: { error: 'You are not authorized to access any organization other than your own' }
  end
end
