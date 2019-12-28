
require 'redmine'

Redmine::Plugin.register :time_task_overrun do
  name 'Output time оverrun plugin'
  author 'Pecherskiy Alexei'
  version '0.9'
end

object_to_prepare = Rails.configuration
#patchs connection
object_to_prepare.to_prepare do
  require_relative "./lib/patches/time_task_overrun/query_patch.rb"
  require_relative "./lib/patches/time_task_overrun/queries_helper_patch.rb"
  Query.send(:include, TimeTaskOverrun::Patches::QueryPatch)
  QueriesHelper.send(:include, TimeTaskOverrun::Patches::QueriesHelperPatch)
end




