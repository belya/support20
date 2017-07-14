class ChatraController < ApplicationController
  include Predictable
  skip_before_filter :verify_authenticity_token
  before_action :set_prompt_value, only: [:take_step]

  def init
    @support_session = SupportSession.create(session_params)
    @support_session.messages.create(message_params)
    @support_session.steps.push(predicted_step)
    send_message
    render json: {success: true}
  end

  def take_step
    @support_session = SupportSession.find_by(chatra_chat_id: body["client"]["chatId"])
    if @support_session.created? && client_message?
      @support_session.last_step.evaluate(@support_session, params)
      @support_session.steps.push(predicted_step)
      send_message
    end
    render json: {success: true}
  end

  private
    def client_message?
      body["messages"].last["type"] == "client"
    end

    def send_message
      RestClient.post(
        Rails.configuration.chatra[:send], 
        {
          clientId: @support_session.chatra_client_id,
          text: translate_step(@support_session.last_step),
          agentId: @support_session.chatra_agent_id
        }.to_json
      )
    end

    def session_params
      {
        page: Page.first,
        chatra_chat_id: body["client"]["chatId"],
        chatra_client_id: body["client"]["id"],
        chatra_agent_id: body["agent"]["id"]
      }
    end

    def message_params
      {
        text: body["message"]["text"]
      }
    end

    def body
      @body ||= JSON.parse(request.raw_post)
    end

    def translate_step step
      I18n.t(
        "steps.#{step.class.name.underscore.gsub("_step", "")}", 
        step.attributes.symbolize_keys
      )
    end

    def set_prompt_value
      params.merge!(value: body["messages"].last["text"])
    end
end
