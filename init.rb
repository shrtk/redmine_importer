# frozen_string_literal: true

require 'redmine'
require_relative 'lib/redmine_importer/patches/settings_controller_patch'

# Redmine loads plugin initializers inside its to_prepare callback. Apply the
# patch here so that it is reapplied when Rails reloads SettingsController.
unless SettingsController < RedmineImporter::Patches::SettingsControllerPatch
  SettingsController.prepend RedmineImporter::Patches::SettingsControllerPatch
end

Redmine::Plugin.register :redmine_importer do
  name 'Issue Importer'
  author 'Martin Liu / Leo Hourvitz / Stoyan Zhekov / Jérôme Bataille / Agileware Inc.'
  description 'Issue import plugin for Redmine.'
  version '3.0.1'

  settings default: { 'max_csv_rows' => '5000' },
           partial: 'settings/redmine_importer_settings'

  project_module :importer do
    # Every action must be declared here so that ImporterController's
    # `authorize` filter can also protect the result/run pages (#117121).
    permission :import, importer: %i[index match result run]
  end
  menu :project_menu,
       :importer,
       { controller: 'importer', action: 'index' },
       caption: :label_import,
       before: :settings,
       param: :project_id
end
