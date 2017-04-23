class SupportSessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :set_support_session, except: [:create]

  def create
    @support_session = SupportSession.create(step_ids: [predicted_step.id])
    @support_session.messages.create(message_params)
    render :show
  end

  def show
  end

  def take_step
    if @support_session.created?
      @support_session.update(step_ids: @support_session.step_ids + [predicted_step.id])
    end
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
      FactoryGirl.create([:alert_step, :prompt_step, :server_step, :finish_step].sample)
    end

    def await_if_finish_step
      if !@support_session.step_ids.empty? && Step.find(@support_session.step_ids.last).type == "FinishStep"
        @support_session.await!
      end
    end
end
