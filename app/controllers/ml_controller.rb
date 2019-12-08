class MlController < ActionController::Base
    class << self
        include Rails.application.routes.url_helpers
    end

    before_action :check_api_key

    API_KEY = ENV["ML_API_KEY"] || "Test"
    API_HOST = ENV["ML_URL"] || "http://localhost:8000"

    def check_api_key
        if request.headers["x-api-key"] == API_KEY
            #everything is fine
        else
            render json: {}, status: 401
        end
    end

    def samples 
        if params["q"].present?
            samples = Sample.ransack(params["q"])
        else
            samples = Sample.all
        end
        samples = samples.distinct

        begin
            # Set a reasonable content type
            response.headers['Content-Type'] = 'application/zip'
            # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
            response.headers['X-Accel-Buffering'] = 'no'
            # Create a wrapper for the write call that quacks like something you
            response.headers["Content-Disposition"] = "attachment; filename=\"samples.zip\""
            response.status = 200
            w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
                ZipTricks::Streamer.open(w) { |zip| 
                samples.pluck_in_batches(:id, :type, :file_name, batch_size: 500) {|batch| 
                    batch.each{|id, type, file_name|
                        sample_type = type.constantize
                        zip.write_deflated_file(file_name) { |sink|
                            sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id)).lazy.each{|row|
                                sink.write(row)
                            }
                        }
                    }
                }
            }   
        rescue => e
            pp "Samples export failed :#{e}"
            response.status = 500    
        ensure
            response.stream.close
        end
    end 

    def version
        #render json: { version: MLVersion.active.first }, status: :ok
        render json: {version: "samples_2019_12_08_19-24-47"}, status: :ok
    end

    def self.classify_sample(sample)
        file = sample.temp_file
        begin
            response = RestClient.post("#{API_HOST}/classify",  {sample: file}, headers: {accept: :json, "x-api-key": API_KEY})
            if response.code != 200 
                return false
            end
        ensure
           file.close
           file.unlink 
        end

        json = JSON.parse(response.body)
       
        #deal with json
    end
    
    def self.train(q)
        response = RestClient.post("#{API_HOST}/train",  {samples: export_samples_url(host: Settings.server_domain)}.to_json, headers: {accept: :json, "x-api-key": API_KEY})
        if response.code != 200 
            return false
        end

        json = JSON.parse(response.body)
       
        #deal with json
    end

    def self.update_versions
        response = RestClient.get("#{API_HOST}/versions", {content_type: :json, accept: :json, "x-api-key": API_KEY})
        if response.code != 200 
            return false
        end
        json = JSON.parse(response.body)
        json[:versions].each{|version|
            ml_ver = MLVersion.find_by(version: version[:name])
            if !ml_ver.present? 
                MLVersion.create!(version)
            else
                ml_ver.update!(version)
            end 
        }
    end
end