class ChatraController < ApplicationController
  include Predictable
  skip_before_filter :verify_authenticity_token
  before_action :set_prompt_value, only: [:take_step]

  def take_step   
    @support_session = SupportSession.find_or_create_by(session_params)
    @support_session.messages.create message_params
    if @support_session.created? && client_message?
      @support_session.last_step.evaluate(@support_session, params)
      @support_session.steps.push(predicted_step)
      send_message
    end
  end

  private
    def client_message?
      params[:messages].last[:type] == "client"
    end

    def send_message
      RestClient.post(
        Rails.configuration.chatra[:send], 
        {
          clientId: @support_session.chatra_client_id,
          text: translate_step(@support_session.last_step),
        }.to_json,
        content_type: :json, 
        accept: :json,
        Authorization: "Chatra.Simple #{Rails.configuration.chatra[:public_key]}:#{Rails.configuration.chatra[:private_key]}"
      )
    end

    def session_params
      {
        page: Page.last,
        chatra_chat_id: params[:client][:chatId],
        chatra_client_id: params[:client][:id]
      }
    end

    def message_params
      {
        text: params[:messages].last[:text]
      }
    end

    def translate_step step
      I18n.t(
        "steps.#{step.class.name.underscore.gsub("_step", "")}", 
        step.attributes.symbolize_keys
      )
    end

    def set_prompt_value
      params.merge!(value: params[:messages].last[:text])
    end
end
