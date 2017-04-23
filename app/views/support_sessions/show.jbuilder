json.id @support_session.id
json.status @support_session.status
json.messages @support_session.messages do |message|
  json.id message.id
  json.text message.text
end

json.steps Step.where(id: @support_session.step_ids) do |step|
  json.id step.id
  json.type step.type.underscore.split("_").first
  json.partial! "support_sessions/#{step.type.underscore}", step: step
end

json.values @support_session.values