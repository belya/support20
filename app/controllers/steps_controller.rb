class StepsController < ApplicationController
  before_action :set_step, only: [:edit, :update, :destroy]
  def index
    @steps = Step.all
  end

  def new
    @step = Step.new
  end

  def create
    @step = Step.new(step_params)
    if @step.save
      flash[:notice] = I18n.t('flash.steps.create.notice')
      redirect_to steps_url
    else
      flash[:alert] = I18n.t('flash.steps.create.alert')
      render :new
    end
  end

  def edit
  end

  def update
    if @step.update(step_params)
      flash[:notice] = I18n.t('flash.steps.update.notice')
      redirect_to steps_url
    else
      flash[:alert] = I18n.t('flash.steps.update.alert')
      render :edit
    end
  end

  def destroy
    @step.destroy
    flash[:notice] = I18n.t('flash.steps.destroy.notice')
    redirect_to steps_url
  end

  private
    def step_params
      params.require(:step).permit(
        :type, 
        :text, 
        :value_type, 
        :value_name,
        :action_name,
        :description
      )
    end

    def set_step
      @step = Step.find(params[:id])
    end
end
