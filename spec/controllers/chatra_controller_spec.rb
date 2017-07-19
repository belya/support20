require 'rails_helper'

RSpec.describe ChatraController, type: :controller do
  context "take a step and predict another" do
    before do
      create :page
    end

    let :server_step do
      create :server_step, action: "step(support_session).update(values: {'server_key' => 'server_value'})"
    end

    let :support_session do
      create :support_session, 
        steps: [server_step], 
        chatra_chat_id: body[:client][:chatId],
        chatra_client_id: body[:client][:id]
    end

    context "new session" do
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

      before do
        stub_request(:post, Rails.configuration.model_url)
          .with(headers: {'Accept'=>'application/json'})
          .to_return(status: 200, body: {
            prediction: create(:alert_step).dataset_id
          }.to_json, headers: {})
        stub_request(:post, Rails.configuration.chatra[:send])
          .with(headers: {
            'Accept'=>'application/json',
            'Authorization'=>"Chatra.Simple #{Rails.configuration.chatra[:public_key]}:#{Rails.configuration.chatra[:private_key]}"
          }, body: {
            "clientId" => body[:client][:id],
            "text" => AlertStep.first.text,
          }.to_json)
        post :take_step, params: body
      end

      it "checks new session" do
        expect(SupportSession.first).to have_attributes(
          chatra_client_id: body[:client][:id],
          chatra_chat_id: body[:client][:chatId]
        )
      end

      it "checks first message" do
        expect(SupportSession.first.messages.first).to have_attributes(
          text: body[:messages][0][:text],
          client: true
        )
      end

      it "checks first step" do
        expect(SupportSession.first.steps).not_to be_empty
      end
    end

    context "created session" do
      context "last message is from client" do
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

        before do
          support_session
          stub_request(:post, Rails.configuration.model_url)
            .with(headers: {'Accept'=>'application/json'})
            .to_return(status: 200, body: {
              prediction: create(:alert_step).dataset_id
            }.to_json, headers: {})
          stub_request(:post, Rails.configuration.chatra[:send])
            .with(headers: {
              'Accept'=>'application/json',
              'Authorization'=>"Chatra.Simple #{Rails.configuration.chatra[:public_key]}:#{Rails.configuration.chatra[:private_key]}"
            }, body: {
              "clientId" => body[:client][:id],
              "text" => AlertStep.first.text,
            }.to_json)
          post :take_step, params: body
        end

        it "checks support session" do
          expect(support_session.id).to eq(assigns(:support_session).id)
        end

        it "checks last step evaluation" do
          expect(SupportSession.first.values["server_key"]).to eq("server_value")
        end

        it "checks value param for prompt step" do
          expect(subject.send(:params)[:value]).to eq(body[:messages][0][:text])
        end

        it "checks client message" do
          expect(SupportSession.first.messages.first).to have_attributes(
            text: body[:messages][0][:text],
            client: true
          )
        end

        it "checks agent message" do
          expect(SupportSession.first.messages.last).to have_attributes(
            text: AlertStep.first.text,
            client: false
          )
        end
      end

      context "last message is from agent" do
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
              type: "agent",
              text: "Hi there! Did you receive your tracking number?",
            }]
          }
        end

        it "checks step" do
          support_session
          expect {
            post :take_step, params: body
          }.not_to change{SupportSession.last.steps.length}
        end

        it "checks agent message" do
          post :take_step, params: body
          expect(SupportSession.last.messages.first).to have_attributes(
            text: body[:messages][0][:text],
            client: false
          )
        end
      end
    end

    context "not created session" do
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

      it "checks no new step" do
        support_session.waiting!
        expect {
          post :take_step, params: body
        }.not_to change{SupportSession.last.steps.length}
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
