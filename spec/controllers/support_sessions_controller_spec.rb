require 'rails_helper'

RSpec.describe SupportSessionsController, type: :controller do
  render_views

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
        support_session.step_ids += [
          create(:alert_step).id,
          create(:prompt_step).id,
          create(:server_step).id,
          create(:finish_step).id,
          create(:support_step).id
        ]
        support_session.save
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

      context "steps" do
        it "checks id" do
          expect_json('steps.0', id: Step.first.id)
        end

        it "checks type" do
          expect_json('steps.0', type: Step.first.type.underscore.split("_")[0])
        end

        it "checks text" do
          expect_json('steps.0', text: AlertStep.first.text)
        end

        it "checks value type" do
          expect_json('steps.1', value_type: PromptStep.first.value_type)
        end

        it "checks value" do
          expect_json('steps.1', value: PromptStep.first.value)
        end

        it "checks action" do
          expect_json('steps.2', action: ServerStep.first.action)
        end
      end
    end
  end

  context "create" do
    before do
      post :create, params: {message: {text: "Some message"}}
    end

    it "checks session" do
      expect(SupportSession.first).not_to be_nil
    end

    it "checks message" do
      expect(Message.first.text).to eq("Some message")
    end

    it "checks step" do
      expect(Step.first).not_to be_nil
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
      expect(Message.first.text).to eq("Some message")
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
    end
  end

  context "predict next step" do
    let :support_session do
      create :support_session
    end

    before do
      post :predict, params: {id: support_session.id}
    end

    it "checks step" do
      expect(Step.first).not_to be_nil
    end

    it "checks render" do
      expect(subject).to render_template("support_sessions/show")
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
    it "checks step" do
      expect(subject.send(:predicted_step)).not_to be_nil
    end
  end

  context "make predicted step" do
    it "checks step" do
    end
  end
end
