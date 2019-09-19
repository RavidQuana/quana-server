module Exportable
  extend ActiveSupport::Concern

  module ClassMethods
    attr_reader :exportable_methods

    def stream_query_rows(sql_query, options="WITH CSV HEADER")
      conn = ActiveRecord::Base.connection.raw_connection
      conn.copy_data "COPY (#{sql_query}) TO STDOUT #{options};" do
        while row = conn.get_copy_data
          yield row
        end
      end
    end

    def stream_file_csv_report(query)
      #query_options = "WITH CSV HEADER"
      # Note that if you have a custom select in your query
      # you may need to generate the header yourself. e.g.
      # => stream.write "Created Date,Ordered Date,Price,# of Items"
      # => query_options = "WITH CSV" # note the lack of 'HEADER'
      stream_file(self.name, "csv") do |stream|
        self.stream_query_rows(query.to_sql, "WITH CSV") do |row_from_db|
          stream.write row_from_db
        end
      end
    end
  
    def stream_csv_report(query)
      #query_options = "WITH CSV HEADER"
      # Note that if you have a custom select in your query
      # you may need to generate the header yourself. e.g.
      # => stream.write "Created Date,Ordered Date,Price,# of Items"
      # => query_options = "WITH CSV" # note the lack of 'HEADER'
      Enumerator.new do |yielder|
        self.stream_query_rows(query.to_sql, "WITH CSV") do |row_from_db|
          yielder << row_from_db
        end
      end
    end
    
    def stream_csv_report_exportable(query, exportable_data)
      #query_options = "WITH CSV HEADER"
      # Note that if you have a custom select in your query
      # you may need to generate the header yourself. e.g.
      # => stream.write "Created Date,Ordered Date,Price,# of Items"
      # => query_options = "WITH CSV" # note the lack of 'HEADER'
      query = query.joins(exportable_data[:joins]) if exportable_data[:joins].present?
      query = query.select(exportable_data[:columns].map{|column|
        if column.is_a? Symbol
          table_name + "." + column.to_s
        else
          column
        end
      })
      pp query.to_sql
      Enumerator.new do |yielder|
        self.stream_query_rows(query.to_sql, "WITH CSV") do |row_from_db|
          yielder << row_from_db
        end
      end
    end

    def exportables
      @exportables || [{
          name: I18n.t('active_admin.data_export.data'),
          columns: column_names
      }]
    end

    def exportable(exportables)
      @exportables = exportables
    end

    def to_xlsx(filters)
      p = Axlsx::Package.new
      wb = p.workbook

      wb.styles do |s|
        styling = {
            base: s.add_style(xlsx_base_style),
            meta: s.add_style(xlsx_meta_style),
            header: {
                base: s.add_style(xlsx_header_style),
                id: s.add_style(xlsx_id_header_style)
            },
            row: {
                odd: {
                    base: s.add_style(xlsx_odd_row_style),
                    id: s.add_style(xlsx_odd_id_row_style)
                },
                even: {
                    base: s.add_style(xlsx_even_row_style),
                    id: s.add_style(xlsx_even_id_row_style)
                }
            }
        }

        exportables.each_with_index do |exp, i|
          sheet_name = exp[:name]
          sheet_source = exp[:source]
          sheet_columns = exp[:columns]

          resource_name = sheet_source ? sheet_source[:resource].underscore : name.underscore

          wb.add_worksheet(name: sheet_name) do |sheet|
            sheet.sheet_view.right_to_left = true

            # add report meta-data to first sheet
            if i == 0
              sheet.add_row [self.human_attribute_name(resource_name.pluralize)], style: styling[:base]
              sheet.merge_cells('A1:B1')

              add_space sheet, 2

              sheet.add_row [
                                I18n.t("active_admin.data_export.report_date"),
                                I18n.l(Time.current.to_date, format: :default)
                            ], style: [styling[:meta], styling[:base]]

              sheet.add_row [
                                I18n.t("active_admin.data_export.report_time"),
                                I18n.l(Time.current, format: :short)
                            ], style: [styling[:meta], styling[:base]]

              add_space sheet, 2
            end

            # handle headers
            headers = sheet_columns.map {|m|
              key = m.is_a?(Hash) ? m.keys.first : m
              self.human_attribute_name(key)
            }

            style = headers.map {|h| styling[:header][:base]}
            style[0] = styling[:header][:id]

            sheet.add_row headers, style: style

            # handle data
            data = exportable_data(sheet_source, sheet_columns)

            data.each_with_index do |row, i|
              if (i + 1) % 2 == 0
                style = row.map {|h| styling[:row][:even][:base]}
                style[0] = styling[:row][:even][:id]
              else
                style = row.map {|h| styling[:row][:odd][:base]}
                style[0] = styling[:row][:odd][:id]
              end

              sheet.add_row row, style: style
            end

            sheet.column_widths *Array.new(headers.length, 20)
          end
        end

        wb.add_worksheet(name: I18n.t('active_admin.data_export.filters')) do |sheet|
          sheet.sheet_view.right_to_left = true

          sheet.add_row [
                            I18n.t("active_admin.data_export.key"),
                            I18n.t("active_admin.data_export.value")
                        ], style: styling[:row][:odd][:base]

          filters.each do |filter|
            sheet.add_row [
                              filter['key'],
                              filter['value']
                          ], style: styling[:row][:odd][:base]
          end
        end
      end

      p.to_stream
    end

    private

    def exportable_data(sheet_source, sheet_columns)
      data = []

      if sheet_source.present?
        resource, foreign_key = sheet_source[:resource].constantize, sheet_source[:attach_via]
        subset = resource.where(foreign_key => pluck(:id))
      else
        subset = self
      end

      subset.find_in_batches(batch_size: 250) do |batch|
        batch.each do |record|
          data << sheet_columns.map {|m|
            begin
              func = m.is_a?(Hash) ? m.values.first : m
              func.is_a?(Proc) ? func.call(record) : record.send(func)
            rescue => e
              pp e.message
              Bugsnag.notify(e)
              break
            end
          }
        end
      end

      return data
    end

    def add_space(sheet, rows)
      rows.times.each do |row|
        sheet.add_row [nil]
      end
    end

    def xlsx_base_style
      {
        b: true,
        name: 'Calibri',
        alignment: {
          horizontal: :center,
          vertical: :center,
          wrap_text: true
        }
      }
    end

    def xlsx_meta_style
      xlsx_base_style.merge({
        bg_color: 'dbdbdb',
        alignment: {
          horizontal: :right
        }
      })
    end

    def xlsx_header_style
      xlsx_base_style.merge({
        fg_color: 'ffffff',
        bg_color: '202356'
      })
    end

    def xlsx_id_header_style
      xlsx_base_style.merge({
        fg_color: 'ffffff',
        bg_color: '4a4a4a'
      })
    end

    def xlsx_row_style
      xlsx_base_style.merge({
        b: false,
        border: {
          style: :thin,
          color: '000000'
        }
      })
    end

    def xlsx_odd_row_style
      xlsx_row_style
    end

    def xlsx_odd_id_row_style
      xlsx_row_style.merge({
        b: true,
        bg_color: 'ddebf7'
      })
    end

    def xlsx_even_row_style
      xlsx_row_style.merge({
        bg_color: 'ededed'
      })
    end

    def xlsx_even_id_row_style
      xlsx_row_style.merge({
        b: true,
        bg_color: 'bdd7ee'
      })
    end
  end
end