class MlController < ActionController::Base
    before_action :check_api_key

    def check_api_key
        if request.headers["x-api-key"] == (ENV["ML_API_KEY"] || "Test")
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
        render json: { version: MLVersion.active.first }, status: :ok
    end

    def self.classify_sample(sample)
        file = sample.temp_file
        begin
            response = RestClient.post("http://localhost:3000/classify",  :sample => file, {accept: :json, "x-api-key": "Test"}
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

    def self.update_versions
        response = RestClient.get("http://localhost:3000/versions", {content_type: :json, accept: :json, "x-api-key": "Test"}
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