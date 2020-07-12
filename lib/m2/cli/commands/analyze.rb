require "date"
require "dry/cli"
require "tty-table"

module M2
  module CLI
    module Commands
      class Analyze < Dry::CLI::Command
        desc "Analyze scraped projects"

        def call(**_options)
          projects = Project.all
          projects = projects.select { |project| project.price.match?("S/") }
          projects = projects.select { |project| project.date == Date.today }
          projects = projects.select { |project| project.bedrooms > 1 }
          projects = projects.select { |project| project.price_as_number <= 380_000 }
          projects = projects.select { |project| project.area_as_number >= 60 }
          projects = projects.select { |project| project.stage != "En planos" }
          sorted_projects = projects.sort_by(&:price_as_number)

          results = sorted_projects.map.with_index do |project, index|
            color = :white

            if index == 0
              color = :green
            end

            if index == sorted_projects.length - 1
              color = :red
            end

            [
              format(project.project, color),
              format(project.model, color),
              format(project.bedrooms, color),
              format(project.area, color),
              format(project.price, color),
              format("#{project.currency} #{sprintf('%.2f', project.price_per_m2)}", color),
              format(project.due_date, color),
              format(project.stage, color),
            ]
          end

          table = TTY::Table.new(["Project", "Model", "Bedrooms", "Area", "Price", "Price/m2", "Due Date", "Stage"], results)
          renderer = TTY::Table::Renderer::ASCII.new(table)

          puts table.render(:ascii, alignments: [:left, :left, :right, :right, :right, :right], padding: [0, 1])
        end

        def format(string, color = :white)
          pastel = Pastel.new
          pastel.bold.send(color, string)
        end
      end
    end
  end
end