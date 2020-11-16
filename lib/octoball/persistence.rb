# frozen_string_literal: true

class Octoball
  module ShardedPersistence
    # cover methods using `self.class.connection`.
    # NOTE: decrement! is implemented using increment!
    [:update_columns, :increment!, :reload, :_delete_row, :_touch_row, :_update_row, :_create_record,
     :transaction, :with_transaction_returning_status].each do |method|
      class_eval <<-"END", __FILE__, __LINE__ + 1
        def #{method}(*args, &block)
          return super if !current_shard || current_shard == ActiveRecord::Base.current_shard
          ActiveRecord::Base.connected_to(shard: current_shard, role: Octoball.current_role) do
            super
          end
        end
        ruby2_keywords(:#{method}) if respond_to?(:ruby2_keywords, true)
      END
    end

    private

    def init_internals
      super
      @current_shard = self.class.connection.current_shard
    end
  end

  ::ActiveRecord::Base.prepend(ShardedPersistence)
end
