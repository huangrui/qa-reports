# TODO: not needed once updated to Rails 3.1 or later

module ActiveRecord
  module Associations
    class AssociationCollection
        def add_record_to_target_with_callbacks(record)
          callback(:before_add, record)
          yield(record) if block_given?
          @target ||= [] unless loaded?
          if @reflection.options[:uniq] && index = @target.index(record)
            @target[index] = record
          else
            @target << record
          end          
          callback(:after_add, record)
          set_inverse_instance(record, @owner)
          record
        end
    end
  end
end

