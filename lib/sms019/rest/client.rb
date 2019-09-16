module SMS019
	module REST
		class Client
			SENDER_ID_USER_DEFINED = 0
			SENDER_ID_ASSIGN_RANDOM = 1
			GATEWAY_URL = 'https://019sms.co.il/api'

			def initialize(username, password, options={})
				@username = username
				@password = password
				@default_sender_id = options[:sender_id]
			end

			def send(message, recipients, options={})
				send_request outbound_xml(message, recipients, options)
			end

			def fetch(from=1.hour.ago, to=Time.zone.now)
				send_request inbound_xml(from, to)
			end

			def dlr(ids, from=1.hour.ago, to=Time.zone.now)
				send_request dlr_xml(ids, from, to)
			end

			def default_sender_id
				@default_sender_id
			end

			def default_sender_id=(v)
				@default_sender_id = v
			end

			private
				def send_request(xml)
			        begin
			            response = RestClient.post GATEWAY_URL, xml
			            Hash.from_xml(Nokogiri::XML(response).to_s.gsub('\n', ''))	
			        rescue => e
			            Bugsnag.notify(e)
			        end
				end		

				def credentials_xml
			        "
		    			<user>
		    				<username>#{@username}</username>
		    				<password>#{@password}</password>
		    			</user>
					"				
				end

				def source_xml(options)
					randomize = options[:randomize] ? SENDER_ID_ASSIGN_RANDOM : SENDER_ID_USER_DEFINED
					sender_id = options[:sender_id] || @default_sender_id

					"
						<source>#{sender_id}</source>
						<response>#{randomize}</response>
					"
				end

				def destinations_xml(recipients)
					phone_numbers = recipients.map { |recipient| "<phone>#{recipient}</phone>" }.join('')
			    	"<destinations>#{phone_numbers}</destinations>"
				end

				def message_xml(message)
					"<message>#{message}</message>"
				end

				def outbound_xml(message, recipients, options)
			        "
			        	<?xml version='1.0' encoding='UTF-8'?>
			    		<sms>
			    			#{credentials_xml}
			    			#{source_xml(options)}
			    			#{destinations_xml(recipients)}
							#{message_xml(message)}
						</sms>
					"
			    end

				def inbound_xml(from=1.hour.ago, to=Time.zone.now)
			        "
						<?xml version='1.0' encoding='UTF-8'?>
						<incoming>
							#{credentials_xml}
							<from>#{I18n.l(from, format: :sms)}</from>
							<to>#{I18n.l(to, format: :sms)}</to>
						</incoming>
					"	
				end

			    def dlr_xml(ids, from=10.minutes.ago, to=Time.zone.now)
			        transactions = ids.map { |id| 
			    		"<external_id>#{id}</external_id>" 
			    	}.join('') 

			        "
						<?xml version='1.0' encoding='UTF-8'?>
						<dlr>
							#{credentials_xml}
			    			<transactions>#{transactions}</transactions>
							<from>#{I18n.l(from, format: :sms)}</from>
							<to>#{I18n.l(to, format: :sms)}</to>
						</dlr>
					"		    	
			    end
		end
	end
end