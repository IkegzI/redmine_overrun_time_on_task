require_dependency 'queries_helper'
require_dependency 'issue_query'
module TimeTaskOverrun
  module Patches
    module QueriesHelperPatch
      include Redmine::I18n

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :column_value, :column_value_ext
        end
      end

      #
      module InstanceMethods
        #data processing in the column total_spend_hours
        def column_value_ext(column, item, value)
          case column.name
          when :id
            link_to value, issue_path(item)
          when :subject
            link_to value, issue_path(item)
          when :parent
            value ? (value.visible? ? link_to_issue(value, :subject => false) : "##{value.id}") : ''
          when :description
            item.description? ? content_tag('div', textilizable(item, :description), :class => "wiki") : ''
          when :last_notes
            item.last_notes.present? ? content_tag('div', textilizable(item, :last_notes), :class => "wiki") : ''
          when :done_ratio
            progress_bar(value)
          when :relations
            content_tag('span',
                        value.to_s(item) { |other| link_to_issue(other, :subject => false, :tracker => false) }.html_safe,
                        :id => value.css_classes_for(item))
          when :hours, :estimated_hours
            format_hours(value)
          when :spent_hours
            link_to_if(value > 0, format_hours(value), project_time_entries_path(item.project, :issue_id => "#{item.id}"))
          when :total_spent_hours
            value = (value.to_i == value ? value.to_i : value)
            if item.total_spent_hours
              link = project_time_entries_path(item.project, :issue_id => "#{item.id}")
              val = (
              if (item.estimated_hours.nil? || item.total_spent_hours.nil?)
                0
              else
                res = (item.estimated_hours - item.total_spent_hours) * -1
                if res.to_i == res
                  res.to_i
                else
                  res
                end
              end)
              if value > 0
                link_to(format_hours(value), link) +
                    (link_to(' (+' + "#{val}" + ')', link, style: 'color:#cc0000',) if val > 0)
                # link_to_if(val > 0, ' ('+ (val > 0  ? '+' : '') + format_hours(val) + ')', link, style: (val < 0 ? '' : 'color:#cc0000')
              end
            end
          when :attachments
            value.to_a.map { |a| format_object(a) }.join(" ").html_safe
          else
            format_object(value)
          end
        end

      end
    end
  end
end