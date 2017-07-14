require 'rails_helper'

RSpec.describe ChatraController, type: :controller do
  context "init" do    
    let :body do
      {
        agent: {
          id: "bnRzp4CioKudG4aHm"
        },
        client: {
          id: "vfg1y4h4ioapl1cx0trw1mujk6den021zs9b2q8",
          chatId: "aC4krWMZWLYzz9sKZ",
        },
        message: {
          text: "Hi there! Did you receive your tracking number?",
        }
      }
    end

    before do
      create :page
      create :alert_step
      stub_request(:get, Rails.configuration.model_url)
        .with(headers: {'Accept'=>'*/*'})
        .to_return(status: 200, body: {
          prediction: Step.first.dataset_id
        }.to_json, headers: {})
      stub_request(:post, Rails.configuration.chatra[:send])
        .with(headers: {'Accept'=>'*/*'}, body: {
          "clientId" => body[:client][:id],
          "text" => Step.first.text,
          "agentId" => body[:agent][:id]
        }.to_json)
        .to_return(status: 200)
      post :init, body: body.to_json
    end

    it "checks session" do
      expect(SupportSession.first).not_to be_nil
    end

    pending "checks page"

    pending "first message from agent"

    it "checks message" do
      expect(SupportSession.first.messages.first.text).to eq(body[:message][:text])
    end

    it "checks chatra chat id" do
      expect(SupportSession.first.chatra_chat_id).to eq(body[:client][:chatId])
    end

    it "checks chatra client id" do
      expect(SupportSession.first.chatra_client_id).to eq(body[:client][:id])
    end

    it "checks chatra agent id" do
      expect(SupportSession.first.chatra_agent_id).to eq(body[:agent][:id])
    end

    it "checks step" do
      expect(SupportSession.first.steps.length).to eq(1)
    end

    it "checks success" do
      expect(response.body).to eq({success: true}.to_json)
    end
  end

  context "take a step and predict another" do
    let :body do
      {
        agents: [{
          id: "bnRzp4CioKudG4aHm"
        }],
        client: {
          id: "vfg1y4h4ioapl1cx0trw1mujk6den021zs9b2q8",
          chatId: "aC4krWMZWLYzz9sKZ",
        },
        messages: [{
          type: "client",
          text: "Hi there! Did you receive your tracking number?",
        }]
      }
    end

    let :server_step do
      create :server_step, action: "step(support_session).update(values: {'server_key' => 'server_value'})"
    end

    let :support_session do
      create :support_session, 
        steps: [server_step], 
        chatra_chat_id: body[:client][:chatId],
        chatra_agent_id: body[:agents][0][:id],
        chatra_client_id: body[:client][:id]
    end

    before do
      create :message, support_session: support_session
      stub_request(:get, Rails.configuration.model_url)
        .with(headers: {'Accept'=>'*/*'})
        .to_return(status: 200, body: {
          prediction: create(:alert_step).dataset_id
        }.to_json, headers: {})
    end

    context "created session" do
      before do
        stub_request(:post, Rails.configuration.chatra[:send])
        .with(headers: {'Accept'=>'*/*'}, body: {
          "clientId" => body[:client][:id],
          "text" => AlertStep.first.text,
          "agentId" => body[:agents][0][:id]
        }.to_json)
        .to_return(status: 200)
      end

      it "checks new step" do
        expect {
          post :take_step, body: body.to_json
        }.to change{SupportSession.first.steps.length}
      end

      it "checks step evaluation" do
        post :take_step, body: body.to_json
        expect(SupportSession.first.values["server_key"]).to eq("server_value")
      end

      it "checks value param for prompt step" do
        post :take_step, body: body.to_json
        expect(subject.send(:params)[:value]).to eq(body[:messages][0][:text])
      end

      it "checks success" do
        post :take_step, body: body.to_json
        expect(response.body).to eq({success: true}.to_json)
      end
    end

    context "last message is agent answer" do
      let :body_with_agent_message do
        {
          agents: [{
            id: "bnRzp4CioKudG4aHm"
          }],
          client: {
            id: "vfg1y4h4ioapl1cx0trw1mujk6den021zs9b2q8",
            chatId: "aC4krWMZWLYzz9sKZ",
          },
          messages: [{
            type: "agent"
          }]
        }
      end

      it "checks no prediction" do
        expect {
          post :take_step, body: body_with_agent_message.to_json
        }.not_to change{SupportSession.first.steps.length}
      end
    end

    context "not created session" do
      it "checks step" do
        SupportSession.first.waiting!
        expect {
          post :take_step, body: body.to_json
        }.not_to change{SupportSession.first.steps.length}
      end
    end
  end

  context "step i18n" do
    let :alert_step do
      create :alert_step
    end

    let :prompt_step do
      create :prompt_step
    end

    let :server_step do
      create :server_step
    end

    let :finish_step do
      create :finish_step
    end

    it "checks alert step" do
      expect(subject.send(:translate_step, alert_step)).to eq(alert_step.text)
    end

    it "checks prompt step" do
      expect(subject.send(:translate_step, prompt_step)).to eq("Please, enter #{prompt_step.value_name}. It should have #{prompt_step.value_type} form")
    end

    it "checks server step" do
      expect(subject.send(:translate_step, server_step)).to eq("Please, wait. We are on the way to #{server_step.action_name}, it will take some seconds...")
    end

    it "checks finish step" do
      expect(subject.send(:translate_step, finish_step)).to eq("That's all our bot can do for you. Was it helpful? If no, our operators are already in touch!")
    end
  end
end
