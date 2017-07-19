require 'rails_helper'

RSpec.feature "Steps", type: :feature do
  context "index" do
    before do
      create :alert_step
      create :prompt_step
      create :server_step
      create :finish_step
      visit steps_url
    end

    it "checks all steps" do
      expect(page).to have_selector('div.step', count: Step.count)
    end

    it "checks alert step" do
      within 'div.step.alert' do
        expect(page).to have_content(AlertStep.first.text)
        expect(page).to have_content(I18n.t('scope.steps.edit'))
      end
    end

    it "checks prompt step" do
      within 'div.step.prompt' do
        expect(page).to have_content(PromptStep.first.value_name)
        expect(page).to have_content(PromptStep.first.value_type)
        expect(page).to have_content(I18n.t('scope.steps.edit'))
      end
    end

    it "checks prompt step" do
      within 'div.step.server' do
        expect(page).to have_content(ServerStep.first.action_name)
        expect(page).to have_content(ServerStep.first.description)
        expect(page).to have_content(I18n.t('scope.steps.edit'))
      end
    end

    it "checks finish step" do
      within 'div.step.finish' do
        expect(page).not_to have_content(I18n.t('scope.steps.edit'))
      end
    end

    it "checks edit link" do
      within 'div.step.server' do
        click_link I18n.t('scope.steps.edit')
        expect(current_url).to eq(edit_step_url(ServerStep.first))
      end
    end

    it "checks new link" do
      click_link I18n.t('scope.steps.new')
      expect(current_url).to eq(new_step_url)
    end
  end

  context "new" do
    before do
      visit new_step_url
    end

    context "selector" do
      it "checks alert step", js: true do
        select 'Alert step', from: 'Type'
        expect(page).to have_selector('div.step.alert')
      end
    end
  end
end
