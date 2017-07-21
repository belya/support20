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
        expect(page).to have_content(I18n.t('scope.steps.destroy'))
      end
    end

    it "checks prompt step" do
      within 'div.step.prompt' do
        expect(page).to have_content(PromptStep.first.value_name)
        expect(page).to have_content(PromptStep.first.value_type)
        expect(page).to have_content(I18n.t('scope.steps.edit'))
        expect(page).to have_content(I18n.t('scope.steps.destroy'))
      end
    end

    it "checks prompt step" do
      within 'div.step.server' do
        expect(page).to have_content(ServerStep.first.action_name)
        expect(page).to have_content(ServerStep.first.description)
        expect(page).to have_content(I18n.t('scope.steps.edit'))
        expect(page).to have_content(I18n.t('scope.steps.destroy'))
      end
    end

    it "checks finish step" do
      within 'div.step.finish' do
        expect(page).not_to have_content(I18n.t('scope.steps.edit'))
        expect(page).not_to have_content(I18n.t('scope.steps.destroy'))
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
      visit new_step_path
    end

    let :server_step_errors do
      step = build :server_step, action_name: nil, description: nil
      step.valid?
      step.errors
    end

    it "checks steps selector", js: true do
      [AlertStep, PromptStep, ServerStep].each do |step|
        select step.model_name.human, from: 'Type'
        expect(page).to have_selector("div.step.#{step.name}")
        expect(page).to have_selector("div.step", count: 1)
      end
    end

    it "checks alert step creation", js: true do
      select 'Alert step', from: 'Type'
      fill_in 'Text', with: 'Some text'
      click_button "Save"

      expect(current_path).to eq(steps_path)
      within "body div.step:first-child" do
        expect(page).to have_content('Some text')
      end
      expect(page).to have_content(I18n.t("flash.steps.create.notice"))
    end

    it "checks prompt step creation", js: true do
      select 'Prompt step', from: 'Type'
      fill_in 'Value name', with: 'Some name'
      fill_in 'Value type', with: 'String'
      click_button "Save"

      expect(current_path).to eq(steps_path)
      within "body div.step:first-child" do
        expect(page).to have_content('Some name')
        expect(page).to have_content('String')
      end
      expect(page).to have_content(I18n.t("flash.steps.create.notice"))
    end


    it "checks server step creation", js: true do
      select 'Server step', from: 'Type'
      fill_in 'Action name', with: 'Some name'
      fill_in 'Description', with: 'Description'
      click_button "Save"

      expect(current_path).to eq(steps_path)
      within "body div.step:first-child" do
        expect(page).to have_content('Some name')
        expect(page).to have_content('Description')
      end
      expect(page).to have_content(I18n.t("flash.steps.create.notice"))
    end

    it "checks invalid step", js: true do
      select 'Server step', from: 'Type'
      click_button "Save"

      expect(page).to have_content(I18n.t("flash.steps.create.alert"))
      server_step_errors.values.each do |errors|
        errors.each do |error|
          expect(page).to have_content(error)
        end
      end
    end
  end

  context "edit" do
    it "checks alert step", js: true do
      create :alert_step
      visit edit_step_path(Step.first)
      fill_in "Text", with: "Some other text"
      click_button "Save"

      expect(current_path).to eq(steps_path)
      within "body div.step:first-child" do
        expect(page).to have_content('Some other text')
      end
      expect(page).to have_content(I18n.t("flash.steps.update.notice"))
    end
  end

  context "destroy" do
    it "checks destroy step", js: true do
      create :alert_step
      visit steps_path
      click_link "Destroy step"
      accept_confirm

      expect(page).to have_content(I18n.t("flash.steps.destroy.notice"))
    end

    pending "checks no destroy without confirmation", js: true do
      create :alert_step
      visit steps_path
      click_link "Destroy step"
      dismiss_confirm

      expect(page).not_to have_content(I18n.t("flash.steps.destroy.notice"))
    end
  end
end
