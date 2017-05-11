require 'rails_helper'

RSpec.describe SupportSessionsController, type: :controller do
  render_views

  context "show" do
    let :support_session do
      create :support_session, values: {key: "value"}
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

      context "values" do
        it "checks value" do
          expect_json('values', key: "value")
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
      post :create, params: {message: {text: "Some message"}}
    end

    it "checks session" do
      expect(SupportSession.first).not_to be_nil
    end

    it "checks message" do
      expect(SupportSession.first.messages.first.text).to eq("Some message")
    end

    it "checks step" do
      expect(SupportSession.first.step_ids.length).to eq(1)
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
        create :server_step, action: "support_session.values['server_key'] = 'server_value'; support_session.save"
      end

      let :support_session do
        create :support_session, step_ids: [server_step.id], values: {"old_key" => "old_value"}
      end

      before do
        allow(subject).to receive(:predicted_step) do
          create :alert_step
        end
        post :take_step, params: {id: support_session.id, values: {"new_key" => "new_value"}}
      end

      it "checks predicted step" do
        expect(subject).to have_received(:predicted_step)
      end

      it "checks new step" do
        expect(SupportSession.first.step_ids.length).to eq(2)
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
        expect(SupportSession.first.step_ids).to be_empty
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
    it "checks step" do
      expect(subject.send(:predicted_step)).not_to be_nil
    end
  end

  context "take server step" do
    it "checks server step" do
    end
  end
end


# Был предсказан support step - показать диалог (клиент), завершить сессию (сервер)
# Был предсказан server step - показать сообщение (клиент), сделать серверное действие (сервер)
# Был предсказан prompt step - пользователь вводит значение (клиент), значение сохраняется в сессии (сервер)


# Вывод - действие выполняется в начале take step, если сессия имеет статус не created, действие не предсказывается 

# Проблема - если предсказан support step, сессия до отправки сообщения все еще имеет статус created
# Решение - переводить в статус waiting сессию с support step после действия take_step, сделать редирект с create на take_step