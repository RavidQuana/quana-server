class MlController < ActionController::Base
    class << self
        include Rails.application.routes.url_helpers
    end

    #skip auth token because its API and not ActiveAdmin
    skip_before_action :verify_authenticity_token

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

    def upload_sample
        #pp params
        #pp params["file"]
        #pp params["upload"]
        #pp params["body"]
        if !params["sample"].present?
            render json: {status: "error", data: null, message: "Sample does not exists"}, status: 400
            return
        end 

        begin
            brand = Brand.find_or_create_by(name: params[:brand])
            product = Product.find_or_create_by(brand: brand, name: params[:product])
        rescue ActiveRecord::RecordNotUnique
            retry
        end
        sampler = Sampler.find_by_name("Test Device")

        records = SampleGamma.from_file(params[:sample].tempfile)

        if records.size < 100
            render json: {status: "error", data: nil, message: "Sample too small"}, status: 200
            return
        end

        samples = SampleGamma.from_records(recods, sampler, :user, params[:id], product, [], params[:note])
        
        render json: {status: "success", data: classify_multiple(samples), message: nil}, status: 200
    end

    def upload_white_sample
        #pp params
        #pp params["file"]
        #pp params["upload"]
        pp params   
        pp params.keys
        if !params["sample"].present?
            render json: {status: "error", data: null, message: "Sample does not exists"}, status: 400
            return
        end 

        sample_file = params[:sample].tempfile

        #pp "#############"
        pp Base64.strict_encode64(sample_file.read)

        begin
            brand = Brand.find_or_create_by(name: params[:brand])
            product = Product.find_or_create_by(brand: brand, name: params[:product])
        rescue ActiveRecord::RecordNotUnique
            retry
        end

        tags = []
        
        if params[:tags].present?
            begin
                tags = JSON.parse(params[:tags])  
            rescue JSON::ParserError => e  
                pp "Failed to parse tags"
            end 
        end

        tags.map!{|tag|
            begin
                tag = Tag.find_or_create_by(name: tag)
            rescue ActiveRecord::RecordNotUnique
                retry
            end
        }   

        sampler = Sampler.find_by_name("Test Device")

        records = SampleGamma.from_file(sample_file)

        if records.size < 100
            render json: {status: "error", data: nil, message: "Sample too small"}, status: 200 
            return
        end

        samples = SampleGamma.from_records(records, sampler, :white, nil, product, tags, params[:note])

        render json: {status: "success", data: classify_multiple(samples), message: nil}, status: 200
    end

    def classify_multiple(samples)
        classifications = []
        samples.each{|s|
            c = s.classification 
            classifications << c if c.present?
        }   
        sum = {
            "Pesticide": 0,
            "Mold": 0,
            "Sativa": 0,
            "Indica": 0,
        }   
        classifications.each{|clas|
            clas.each{|key, value|
                sum[key.to_s] = sum.get(key.to_s, 0) + value
            }
        }
        if classifications.size > 0 
            sum.each{|key, value|
                sum[key] = value / classifications.size
            }
        end
        classifications = []
        sum.each{|key, value|
            classifications << {name: key, percentage: value}
        }
        classifications
    end 

    def samples 
        if params["q"].present?
            samples = Sample.ransack(params["q"]).result
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

    def self.current_version
        MLVersion.active.order(updated_at: :desc).first.name
    end

    def version
        render json: { version: MLVersion.current_version }, status: :ok
    end

    def self.classify_sample(sample)
        file = sample.temp_file
        
        begin
            response = RestClient.post("#{API_HOST}/classify",  {sample: file, version: MlController.current_version}, headers: {accept: :json, "x-api-key": API_KEY})
            if response.code != 200 
                return nil
            end
        rescue StandardError => e
            pp e
            return nil
        ensure
           file.close
           file.unlink 
        end

        json = JSON.parse(response.body)
       
        return json
    end 
    
    def self.train(q)
        response = RestClient.post("#{API_HOST}/train",  {samples: export_samples_url(host: Settings.server_domain, q: q)}.to_json, headers: {accept: :json, "x-api-key": API_KEY})
        if response.code != 200 
            return false
        end

        json = JSON.parse(response.body)
        pp json

        if json['id'].present?
            ml_version = MLVersion.find_by(name: json['id'])
            if !ml_version.present?
                MLVersion.create(name: json['id'], query: q.to_s)
            end
        end
        #deal with json
    end

    def permitted_params
        params.permit!
    end

    def self.update_versions
        response = RestClient.get("#{API_HOST}/versions", {content_type: :json, accept: :json, "x-api-key": API_KEY})
        if response.code != 200 
            return false
        end
        json = JSON.parse(response.body)
        json.each{|version|
            if !MLVersion.where(name: version).exists?
                MLVersion.create!(name: version)
            end 
        }   
        MLVersion.where.not(name: json).delete_all
    end
end