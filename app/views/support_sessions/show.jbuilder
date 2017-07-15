json.id @support_session.id
json.status @support_session.status
json.messages @support_session.messages do |message|
  json.id message.id
  json.text message.text
end

json.steps @support_session.steps do |step|
  json.id step.id
  json.type step.type.underscore.split("_").first
  json.partial! "support_sessions/#{step.type.underscore}", step: step
end

json.values @support_session.values