module Admin
  module Exportable
    extend ActiveSupport::Concern

    def self.included(base)
      resource = base.config.resource_class.name.constantize
      resource_name = resource.name.singularize.underscore

      # patch index action
      base.send(:controller) do
        include( ActionController::Live )

        send(:before_action, only: :index) do |controller|
          if controller.request.format.html?
            @per_page = params[:pagination] unless params[:pagination].blank?
          else
            @per_page = resource.count
          end
        end

      

        send(:define_method, :index) do
          index! do |format|
            format.csv { 
              begin
                # Don't cache anything from this generated endpoint
                response.headers["Cache-Control"] = "no-cache"
                # Tell the browser this is a CSV file
                response.headers["Content-Type"] = "text/csv"
                # Make the file download with a specific filename
                response.headers["Content-Disposition"] = "attachment; filename=\"data.csv\""
                # Don't buffer when going through proxy servers
                response.headers["X-Accel-Buffering"] = "no"
                # Set an Enumerator as the body
                resource.stream_csv_report(collection).lazy.each{|row|
                  response.stream.write(row)
                }
              ensure
                response.stream.close
              end
            }
            format.zip { 
              begin
                # Set a reasonable content type
                response.headers['Content-Type'] = 'application/zip'
                # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
                response.headers['X-Accel-Buffering'] = 'no'
                # Create a wrapper for the write call that quacks like something you
                # can << to, used by ZipTricks
                w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
                ZipTricks::Streamer.open(w) { |zip| 
                  zip.write_deflated_file('data.csv') do |sink|
                    resource.stream_csv_report(collection).lazy.each{|row|
                      sink.write(row)
                    }
                  end
                }
              ensure
                response.stream.close
              end
            }
            format.zip_records { 
              begin
               # Set a reasonable content type
               response.headers['Content-Type'] = 'application/zip'
               # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
               response.headers['X-Accel-Buffering'] = 'no'
               # Create a wrapper for the write call that quacks like something you
               response.headers["Content-Disposition"] = "attachment; filename=\"samples.zip\""
              w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
                ZipTricks::Streamer.open(w) { |zip| 
                collection.pluck_in_batches(:id, :type, :file_name, batch_size: 500) {|batch| 
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
              ensure
                response.stream.close
              end
            }
            format.zip_records_combined { 
              begin
               # Set a reasonable content type
               response.headers['Content-Type'] = 'application/zip'
               # Make sure nginx buffering is suppressed - see https://github.com/WeTransfer/zip_tricks/issues/48
               response.headers['X-Accel-Buffering'] = 'no'
               # Create a wrapper for the write call that quacks like something you
               response.headers["Content-Disposition"] = "attachment; filename=\"samples.zip\""

                w = ZipTricks::BlockWrite.new { |chunk| response.stream.write(chunk) }
                ZipTricks::Streamer.open(w) { |zip| 
                  zip.write_deflated_file("combined.csv") { |sink|
                    collection.pluck_in_batches(:id, :type, batch_size: 2000) {|batch| 
                      batch.each{|id, type|
                        sample_type = type.constantize
                        sample_type.data_type.stream_csv_report(sample_type.data_type.where(sample_id: id)).lazy.each{|row|
                          sink.write(row)
                        }
                      }
                    }
                  }
                }
              ensure
                response.stream.close
              end
            }
            format.xlsx { 
              # Tell Rack to stream the content
              headers.delete("Content-Length")
              # Don't cache anything from this generated endpoint
              headers["Cache-Control"] = "no-cache"
              # Tell the browser this is a CSV file
              headers["Content-Type"] = "text/csv"
              # Make the file download with a specific filename
              headers["Content-Disposition"] = "attachment; filename=\"data.xlsx\""
              # Don't buffer when going through proxy servers
              headers["X-Accel-Buffering"] = "no"
              # Set an Enumerator as the body


              filters = @search.conditions.map {
                |condition| ActiveAdmin::Filters::ActiveFilter.new(base.config, condition.dup)
              }
              filter_data = filters.map {|filter| {
                  key: filter.label,
                  value: filter.values.map {|v| v.try(:id) || v}.join(', ')
              }}

              xlsx_stream = collection.includes(collection.includes_values).to_xlsx(filter_data)

              self.response_body = xlsx_stream
              # Set the status to success
              response.status = 200
            }
          end
        end
      end
    end
  end
end