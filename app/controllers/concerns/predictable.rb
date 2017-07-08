module Predictable
  include ActiveSupport::Concern

  protected
    def predicted_step
      Step.find_by(dataset_id: predict)
    end

    def predict
      RestClient.get(Rails.configuration.model_url, parameters)
    end

    def parameters
      page = @support_session.page.dataset_id
      query = @support_session.messages.first.text
      previous_action = @support_session.last_step.dataset_id || -1
      condition = @support_session.support_session_steps.last.nil? ? nil : @support_session.support_session_steps.last.condition
      condition = ((condition == true) ? 1 : 0) - ((condition == false) ? 1 : 0)
      {
        page: page,
        query: query,
        previous_action: previous_action,
        condition: condition
      }
    end
end