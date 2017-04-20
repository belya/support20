class SupportSessionsController < ApplicationController
  before_action :set_support_session, except: [:create]

  def create
    @support_session = SupportSession.create
    @support_session.messages.create(message_params)
    @support_session.step_ids.push predicted_step.id
    render :show
  end

  def show
  end

  def predict
    @support_session.step_ids.push predicted_step.id
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
      FactoryGirl.create(:alert_step)
    end
end
