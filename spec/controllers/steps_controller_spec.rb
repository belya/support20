require 'rails_helper'

RSpec.describe StepsController, type: :controller do
  let :alert_step_params do
    {
      type: "AlertStep",
      text: "Some another text"
    }
  end

  let :prompt_step_params do
    {
      type: "PromptStep",
      value_name: "Some other value",
      value_type: "Integer"
    }
  end

  let :server_step_params do
    {
      type: "ServerStep",
      action_name: "Some other action",
      description: "Do something"
    }
  end

  context "index" do
    before do
      create :alert_step
      get :index
    end

    it "checks steps" do
      expect(assigns(:steps)).to eq(Step.all)
    end
  end

  context "new" do
    before do
      get :new
    end

    it "checks step" do
      expect(assigns(:step)).not_to be_nil
    end
  end

  context "create" do
    context "valid" do
      before do
        post :create, params: {step: alert_step_params}
      end

      it "checks alert step" do
        expect(Step.last).to have_attributes(alert_step_params)
      end

      it "checks prompt step" do
        post :create, params: {step: prompt_step_params}
        expect(Step.last).to have_attributes(prompt_step_params)
      end

      it "checks server step" do
        post :create, params: {step: server_step_params}
        expect(Step.last).to have_attributes(server_step_params)
      end

      it "checks redirect" do
        expect(subject).to redirect_to(steps_url)
      end

      it "checks notice" do
        expect(flash[:notice]).to eq(I18n.t('flash.steps.create.notice'))
      end

      it "checks step" do
        expect(assigns(:step)).to eq(Step.last)
      end
    end

    context "invalid" do
      before do
        post :create, params: {step: {type: "AlertStep"}}
      end

      it "checks alert" do
        expect(flash[:alert]).to eq(I18n.t('flash.steps.create.alert'))
      end

      it "checks template" do
        expect(subject).to render_template(:new)
      end
    end
  end

  context "edit" do
    let :step do
      create :alert_step
    end

    before do
      get :edit, params: {id: step.id}
    end

    it "checks step" do
      expect(assigns(:step)).to eq(Step.first)
    end
  end

  context "update" do
    context "valid" do
      before do
        create :alert_step
        post :update, params: {id: Step.first.id, step: alert_step_params}
      end

      it "checks alert step parameters" do
        expect(Step.first).to have_attributes(alert_step_params)
      end

      it "checks prompt step parameters" do
        post :update, params: {id: Step.first.id, step: prompt_step_params}
        expect(Step.first).to have_attributes(prompt_step_params)
      end

      it "checks server step parameters" do
        post :update, params: {id: Step.first.id, step: server_step_params}
        expect(Step.first).to have_attributes(server_step_params)
      end

      it "checks notice" do
        expect(flash[:notice]).to eq(I18n.t('flash.steps.update.notice'))
      end

      it "checks redirect" do
        expect(subject).to redirect_to(steps_url)
      end

      it "checks step" do
        expect(assigns(:step)).to eq(Step.first)
      end
    end

    context "invalid" do
      before do
        create :alert_step
        post :update, params: {id: Step.first.id, step: {text: ""}}
      end

      it "checks template" do
        expect(subject).to render_template(:edit)
      end

      it "checks alert" do
        expect(flash[:alert]).to eq(I18n.t('flash.steps.update.alert'))
      end
    end
  end

  context "destroy" do
    before do
      create :alert_step
      post :destroy, params: {id: Step.first.id}
    end

    it "checks notice" do
      expect(flash[:notice]).to eq(I18n.t('flash.steps.destroy.notice'))
    end

    it "checks redirect" do
      expect(subject).to redirect_to(steps_url)
    end

    it "checks delete step" do
      expect(Step.all).to be_empty
    end
  end
end
