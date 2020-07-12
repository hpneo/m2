require "dry/cli"
require "scrap_kit"
require "date"
require "yaml"
require "csv"
require "tty-table"

module M2
  module CLI
    module Commands
      class List < Dry::CLI::Command
        desc "List projects in a table"
        option :format, default: "table", values: %w[table csv], desc: "Output format"

        def call(**options)
          headers = ["Date", "ID", "Project", "Model", "Bedrooms", "Area", "Price", "Due Date", "Stage", "Latitude", "Longitude"]
          projects = YAML.load_file("./projects.yml")
          results = projects.flat_map do |project|
            key = project.keys.first
            value = project.values.first

            recipe = ScrapKit::Recipe.load(
              url: key,
              attributes: {
                title: ".Project-header h1",
                id: "#project_id",
                stage: ".bx-data-project.box-st > table > tbody > tr:nth-child(4) > td:nth-child(2)",
                due_date: ".bx-data-project.box-st > table > tbody > tr:nth-child(5) > td:nth-child(2)",
                latitude: "#latitude",
                longitude: "#longitude",
                info: {
                  selector: [".Project-available-model", { ".name_tipology": value.to_s }],
                  children_attributes: {
                    tipology: "span.name_tipology",
                    bedrooms: "span.bedroom",
                    area: "span.area",
                    price: "span.price"
                  }
                }
              }
            )
            output = recipe.run

            title = output[:title]
            id = key.split("/").last.split("-").find { |part| part.match(/\d/) }
            due_date = output[:due_date]
            stage = output[:stage]
            latitude = output[:latitude]
            longitude = output[:longitude]

            output[:info].map do |item|
              tipology = item[:tipology]
              bedrooms = item[:bedrooms]
              area = item[:area].gsub("m2", "").strip
              area = "#{area} m2"
              price = item[:price]

              [Date.today.to_s, id, title, tipology, bedrooms, area, price, due_date, stage, latitude, longitude]
            end
          rescue
            [[Date.today.to_s, key]]
          end

          if options.fetch(:format) == "csv"
            output = CSV.generate do |csv|
              # csv << headers
              results.each do |row|
                csv << row
              end
            end

            puts output
          else
            table = TTY::Table.new(headers, results)
            renderer = TTY::Table::Renderer::ASCII.new(table)

            puts table.render(:ascii, alignments: [:right, :right, :left, :left, :right, :right, :right], padding: [0, 1])
          end
        end
      end
    end
  end
end