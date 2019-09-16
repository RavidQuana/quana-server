module V1
	module Entities
		module Notifications

			class ClientAction < Grape::Entity
				expose :id, documentation: { type: 'integer' }
				expose :name, documentation: { type: 'string' }
			end

			class NotificationType < Grape::Entity
				expose :id, documentation: { type: 'integer' }
				expose :name, documentation: { type: 'string' }
				expose :client_action, with: 'V1::Entities::Notifications::ClientAction',
							 documentation: { type: 'ClientAction' }
			end

			class Base < Grape::Entity
				expose :id, documentation: { type: 'integer' }
				expose :notification_type, with: 'V1::Entities::Notifications::NotificationType',
							 documentation: { type: 'NotificationType' }
				expose :body, documentation: { type: 'string' }
				expose :linkable_id, documentation: { type: 'integer' }
				expose :linkable_type, documentation: { type: 'string' }
				expose :delivery_status, documentation: { type: 'string' }
				expose :created_at, documentation: { type: 'datetime' }
			end

		end
	end
end