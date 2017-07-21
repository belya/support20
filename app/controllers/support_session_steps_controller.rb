class SupportSessionStepsController < ApplicationController
  before_action :set_support_session, only: [:edit, :destroy, :update]

  def index
    @support_sessions = SupportSession.all
  end

  def edit
  end

  def update
    if @support_session.update(support_session_params)
      flash[:notice] = I18n.t('flash.support_session_steps.update.notice')
      redirect_to support_session_steps_url
    else
      flash[:alert] = I18n.t('flash.support_session_steps.update.alert')
      render :edit
    end
  end

  def destroy
    @support_session.destroy
    flash[:notice] = I18n.t('flash.support_session_steps.destroy.notice')
    redirect_to support_session_steps_url
  end

  private 
    def set_support_session
      @support_session = SupportSession.find(params[:id])
    end

    def support_session_params
      params.require(:support_session)
        .permit(support_session_steps_attributes: [
          :id,
          :step_id,
          :_destroy,
          values: permitted_keys
        ])
    end

    def permitted_keys
      params[:support_session][:support_session_steps_attributes].collect do |step_params|
        step_params[:values].keys if step_params.has_key?(:values)
      end.uniq
    end
end
