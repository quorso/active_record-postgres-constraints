# frozen_string_literal: true

if defined?(::Rails::Railtie)
  module ActiveRecord
    module Postgres
      module Constraints
        class Railtie < ::Rails::Railtie
          initializer 'active_record.postgres.constraints.patch_active_record' do |*_args|
            engine = self
            ActiveSupport.on_load(:active_record) do
              AR_CAS = ::ActiveRecord::ConnectionAdapters

              engine.apply_patch! if engine.pg?
            end
          end

          def apply_patch!
            Rails.logger.info do
              'Applying Postgres Constraints patches to ActiveRecord'
            end
            AR_CAS::TableDefinition.include TableDefinition
            AR_CAS::PostgreSQLAdapter.include PostgreSQLAdapter
            AR_CAS::SchemaCreation.prepend SchemaCreation

            ::ActiveRecord::Migration::CommandRecorder.include CommandRecorder
            ::ActiveRecord::SchemaDumper.prepend SchemaDumper
          end

          def pg?
            config = ActiveRecord::Base.connection_db_config
            return true if config && config.adapter.in?(%w[postgresql postgis])

            Rails.logger.warn do
              'Not applying Postgres Constraints patches to ActiveRecord ' \
                'since the database is not postgres'
            end
            false
          end
        end
      end
    end
  end
end
