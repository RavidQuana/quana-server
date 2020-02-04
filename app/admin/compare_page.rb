ActiveAdmin.register_page "Compares" do
    menu priority: 20, label: proc{ 'Compares' }

    content title: proc{ I18n.t('active_admin.dashboard.title') } do
        div class: "blank_slate_container", id: "dashboard_default_message" do
            
            Sample.active_selected.includes(:product, :brand, :card).each{|sample|
                attributes_table_for sample do
                    data = nil
                    begin
                        data = sample.data.to_a
                        time_name = sample.data_time_column  
                    rescue => e
                        h4 "Unavailable: #{sample.id}"
                        pp "wut"
                        next
                    end 

                    if data.size > 0 
                        min_max = data.map{|row| [
                            row.qcm_1,
                            row.qcm_2,
                            row.qcm_3,
                            row.qcm_4,
                            row.qcm_5]}.flatten.minmax { |a, b| a <=> b }
                            
                        data = data[10..-1]	

                        if data.nil?
                            next
                        end
        
                        space = (min_max[1] - min_max[0]) * 0.1
                        
                        div style:"margin-bottom: 30px" do 
                            div do 
                                [
                                    '<h3 style="display: inline-block;">Sample:</h3>',
                                    link_to(sample.id, [:admin, sample]),
                                    '<h3 style="display: inline-block; margin-left:30px;">Brand:</h3> ',
                                    link_to(sample.brand.name, [:admin, sample.brand]),
                                    '<h3 style="display: inline-block; margin-left:30px;">Product:</h3> ',
                                    link_to(sample.product.name, [:admin, sample.product]),
                                    '<h3 style="display: inline-block; margin-left:30px;">Card:</h3> ',
                                    link_to(sample.card.name, [:admin, sample.card])
                                ].join.html_safe
                            end
                            h4 "Note: #{sample.note}"
                            
                            div line_chart [
                                {name: "qcm_1", data: data.map { |data_record| [data_record[time_name], data_record.qcm_1.to_i - data[10].qcm_1.to_i] }},
                                {name: "qcm_2", data: data.map { |data_record| [data_record[time_name], data_record.qcm_2.to_i - data[10].qcm_2.to_i] }},
                                {name: "qcm_3", data: data.map { |data_record| [data_record[time_name], data_record.qcm_3.to_i - data[10].qcm_3.to_i] }},
                                {name: "qcm_4", data: data.map { |data_record| [data_record[time_name], data_record.qcm_4.to_i - data[10].qcm_4.to_i] }},
                                {name: "qcm_5", data: data.map { |data_record| [data_record[time_name], data_record.qcm_5.to_i - data[10].qcm_5.to_i] }},
                            ], points: false
                        end
                        
                    end
                end
            }
            



        end
    end
end