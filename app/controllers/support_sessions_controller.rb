class SupportSessionsController < ApplicationController
  include Predictable
  skip_before_filter :verify_authenticity_token
  before_action :set_support_session, except: [:create]

  def create
    @support_session = SupportSession.create(session_params)
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
    def session_params
      {
        page: Page.find_by(link: params[:link]), 
        jivo_id: params[:jivo_id]
      }
    end

    def message_params
      params.require(:message).permit(:text)
    end

    def set_support_session
      @support_session = SupportSession.find(params[:id])
    end
end
