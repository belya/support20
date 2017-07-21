require 'rails_helper'

RSpec.describe SupportSessionStepsController, type: :controller do
  context "index" do
    before do
      create :support_session_step
      get :index
    end

    it "checks support session" do
      expect(assigns(:support_sessions)).to eq(SupportSession.all) 
    end
  end

  context "edit" do
    let :support_session_step do
      create :support_session_step
    end

    before do
      get :edit, params: {
        id: support_session_step.support_session.id
      }
    end

    it "checks support session" do
      expect(assigns(:support_session)).to eq(SupportSession.first)
    end
  end

  context "update" do
    context "valid" do
      let :update_params do
        {
          id: SupportSession.first.id,
          support_session: {
            support_session_steps_attributes: [{
              id: nil,
              step_id: Step.first.id,
              values: {"email" => "some"}
            }, {
              id: SupportSessionStep.first.id,
              step_id: Step.first.id,
              values: {"email" => "some another"}
            }]
          }
        }
      end

      let :destroy_params do
        {
          id: SupportSession.first.id,
          support_session: {
            support_session_steps_attributes: [{
              id: SupportSessionStep.first.id,
              _destroy: "1"
            }]
          }
        }
      end

      before do
        create :support_session_step
      end

      it "checks new support step" do
        put :update, params: update_params
        expect(SupportSessionStep.last).to have_attributes(
          step_id: Step.first.id,
          support_session_id: SupportSession.first.id,
          values: {"email" => "some"}
        )
      end

      it "checks updated support step" do
        put :update, params: update_params
        expect(SupportSessionStep.first).to have_attributes(
          id: SupportSessionStep.first.id,
          step_id: Step.last.id,
          values: {"email" => "some another"}
        )
      end

      it "checks destroyed support step" do
        expect {
          put :update, params: destroy_params
        }.to change{SupportSessionStep.count}.by(-1)
      end

      it "checks notice" do
        put :update, params: update_params
        expect(flash[:notice]).to eq(I18n.t('flash.support_session_steps.update.notice'))
      end

      it "checks redirect" do
        put :update, params: update_params
        expect(subject).to redirect_to(support_session_steps_url)
      end
    end

    context "invalid" do
      before do
        create :support_session_step
        put :update, params: {
          id: SupportSession.first.id,
          support_session: {
            support_session_steps_attributes: [{
              id: SupportSessionStep.first.id,
              step_id: nil
            }]
          }
        }
      end

      it "checks alert" do
        expect(flash[:alert]).to eq(I18n.t('flash.support_session_steps.update.alert'))
      end

      it "checks render template" do
        expect(subject).to render_template(:edit)
      end
    end
  end

  context "destroy" do
    before do
      create :support_session
      post :destroy, params: {id: SupportSession.first.id}
    end

    it "checks notice" do
      expect(flash[:notice]).to eq(I18n.t('flash.support_session_steps.destroy.notice'))
    end

    it "checks redirect" do
      expect(subject).to redirect_to(support_session_steps_url)
    end

    it "checks delete session" do
      expect(SupportSession.all).to be_empty
    end
  end
end
