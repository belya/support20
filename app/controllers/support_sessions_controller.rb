class SupportSessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_support_session, except: [:create]

  def create
    @support_session = SupportSession.create(page: Page.find_by(link: params[:link]))
    @support_session.messages.create(message_params)
    @support_session.steps.push(predicted_step)
    render :show
  end

  def show
  end

  def take_step
    @support_session.last_step.evaluate(@support_session, params)
    @support_session.steps.push(predicted_step) if @support_session.created?
    render :show
  end

  def write
    @support_session.messages.create(message_params)
    render :show
  end

  def wait
    @support_session.await!
    render :show
  end

  def attach
    @support_session.attach!
    render :show
  end

  def finish
    @support_session.finish!
    render :show
  end

  private
    def message_params
      params.require(:message).permit(:text)
    end

    def set_support_session
      @support_session = SupportSession.find(params[:id])
    end

    def predicted_step
      page = @support_session.page.dataset_id
      query = @support_session.messages.first.text
      previous_action = @support_session.last_step.dataset_id || -1
      condition = @support_session.support_session_steps.last.nil? ? nil : @support_session.support_session_steps.last.condition
      condition = ((condition == true) ? 1 : 0) - ((condition == false) ? 1 : 0)
      Step.find_by(dataset_id: %x(python #{Rails.configuration.model_path} #{page} #{Shellwords.escape(query)} #{previous_action} #{condition}).to_i)
      # FactoryGirl.create([:alert_step, :prompt_step, :server_step, :finish_step].sample)
    end
end
