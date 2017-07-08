require 'rails_helper'

RSpec.describe SupportSessionsController, type: :controller do
  render_views

  before do
    create :alert_step, dataset_id: 1
  end

  context "show" do
    let :support_session do
      create :support_session
    end

    context "invalid" do
      before do
        get :show, params: {id: support_session}
      end

      it "checks errors" do
        expect_json(errors: support_session.errors.full_messages)
      end
    end

    context "valid" do
      before do
        create :message, support_session: support_session
        support_session.steps += [
          create(:alert_step),
          create(:prompt_step),
          create(:server_step),
          create(:finish_step),
        ]
        support_session.save
        support_session.support_session_steps.first.update(values: {key: "value"})
        get :show, params: {id: support_session}
      end

      it "checks id" do
        expect_json(id: support_session.id)
      end

      it "checks status" do
        expect_json(status: support_session.status)
      end

      context "messages" do
        it "checks id" do
          expect_json('messages.0', id: Message.first.id)
        end

        it "checks text" do
          expect_json('messages.0', text: Message.first.text)
        end
      end

      context "values" do
        it "checks value" do
          expect_json('values', key: "value")
        end
      end

      context "steps" do
        it "checks id" do
          expect_json('steps.0', id: Step.second.id)
        end

        it "checks type" do
          expect_json('steps.0', type: Step.second.type.underscore.split("_")[0])
        end

        it "checks text" do
          expect_json('steps.0', text: AlertStep.second.text)
        end

        it "checks value type" do
          expect_json('steps.1', value_type: PromptStep.first.value_type)
        end

        it "checks value name" do
          expect_json('steps.1', value_name: PromptStep.first.value_name)
        end

        it "checks action" do
          expect_json('steps.2', action_name: ServerStep.first.action_name)
        end
      end
    end
  end

  context "create" do
    before do
      create :page, link: "/some_link"
      post :create, params: {jivo_id: "someid", message: {text: "Some message"}, link: Page.first.link}
    end

    it "checks session" do
      expect(SupportSession.first).not_to be_nil
    end

    it "checks page" do
      expect(SupportSession.first).to have_attributes(page: Page.first)
    end

    it "checks jivo id" do
      expect(SupportSession.first).to have_attributes(jivo_id: "someid")
    end

    it "checks message" do
      expect(SupportSession.first.messages.first.text).to eq("Some message")
    end

    it "checks step" do
      expect(SupportSession.first.steps.length).to eq(1)
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "write message" do
    let :support_session do
      create :support_session
    end

    before do
      post :write, params: {id: support_session.id, message: {text: "Some message"}}
    end

    it "checks message" do
      expect(SupportSession.first.messages.first.text).to eq("Some message")
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "take a step and predict another" do
    context "created session" do
      let :server_step do
        create :server_step, action: "step(support_session).update(values: {'server_key' => 'server_value'})"
      end

      let :support_session do
        create :support_session, steps: [server_step]
      end

      before do
        allow(subject).to receive(:predicted_step) do
          create :alert_step
        end
        post :take_step, params: {id: support_session.id}
      end

      it "checks predicted step" do
        expect(subject).to have_received(:predicted_step)
      end

      it "checks new step" do
        expect(SupportSession.first.steps.length).to eq(2)
      end

      it "checks step evaluation" do
        expect(SupportSession.first.values["server_key"]).to eq("server_value")
      end

      it "checks render" do
        expect(subject).to render_template("support_sessions/show")
      end
    end

    context "not created session" do
      let :support_session do
        create :support_session, status: :waiting
      end

      before do
        post :take_step, params: {id: support_session.id}
      end

      it "checks step" do
        expect(SupportSession.first.steps).to be_empty
      end
    end
  end

  context "wait for operator" do
    let :support_session do
      create :support_session
    end

    before do
      post :wait, params: {id: support_session.id}
    end

    it "checks status" do
      expect(SupportSession.first.status).to eq("waiting")
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "attach operator" do
    let :support_session do
      create :support_session, status: :waiting
    end

    before do
      post :attach, params: {id: support_session.id}
    end

    it "checks status" do
      expect(SupportSession.first.status).to eq("attached")
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "finish" do
    let :support_session do
      create :support_session
    end

    before do
      post :finish, params: {id: support_session.id}
    end

    it "checks status" do
      expect(SupportSession.first.status).to eq("completed")
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "predicted step" do
    before do
      create :support_session
      create :message, support_session: SupportSession.first
      create :support_session_step, support_session: SupportSession.first, step: create(:alert_step)
      subject.instance_variable_set(:@support_session, SupportSession.first)
    end

    let :support_session do
      SupportSession.first
    end

    let :forecast_parameters do
      subject.send(:parameters)
    end

    it "checks request" do
      subject.send(:predict)
      stub_request(:get, Rails.configuration.model_url)
        .to_return { |request| expect(request).to eq(forecast_parameters) }
    end

    context "parameters" do
      it "checks page id" do
        expect(forecast_parameters[:page]).to eq(support_session.page.dataset_id)
      end

      it "checks query" do
        expect(forecast_parameters[:query]).to eq(support_session.messages.first.text)
      end

      it "checks previous action" do
        expect(forecast_parameters[:previous_action]).to eq(support_session.steps.last.dataset_id)
      end

      it "checks empty previous action" do
        support_session.steps.clear
        subject.send(:predicted_step)
        expect(forecast_parameters[:previous_action]).to eq(-1)
      end

      it "checks true condition" do
        support_session.support_session_steps.first.update(condition: true)
        expect(forecast_parameters[:condition]).to eq(1)
      end

      it "checks false condition" do
        support_session.support_session_steps.first.update(condition: false)
        subject.send(:predicted_step)
        expect(forecast_parameters[:condition]).to eq(-1)
      end

      it "checks empty condition" do
        support_session.steps.clear
        subject.send(:predicted_step)
        expect(forecast_parameters[:condition]).to eq(0)
      end
    end
  end
end