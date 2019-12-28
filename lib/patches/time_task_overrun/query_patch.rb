require_dependency 'query'
module TimeTaskOverrun
  module Patches
    module QueryPatch
      include Redmine::I18n
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :columns, :columns_ext
        end
      end

      module InstanceMethods
        #add columns run_time and total spend hours
        def columns_ext
          cols = (has_default_columns? ? default_columns_names : column_names).collect do |name|
              available_columns.find { |col| col.name == name }
          end.compact
          cols.insert(3, available_columns.find { |col| col.name == :total_spent_hours })
          cols.insert(3, available_columns.find { |col| col.name == :estimated_hours })
         (available_columns.select(&:frozen?) | cols).compact
        end
      end
    end
  end
end
