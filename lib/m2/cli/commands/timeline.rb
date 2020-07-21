require "date"
require "dry/cli"
require "tty-table"

module M2
  module CLI
    module Commands
      class Timeline < Dry::CLI::Command
        desc "See projects prices through time"

        def call(**_options)
          projects = Project.all
          projects = projects.select { |project| project.price&.match?("S/") }
          projects = projects.select { |project| project.bedrooms > 1 }
          projects = projects.select { |project| project.price_as_number <= 380_000 }
          projects = projects.select { |project| project.area_as_number >= 60 }
          # projects = projects.select { |project| project.stage != "En planos" }
          sorted_projects = projects.sort_by(&:date)

          dates = projects.map(&:date).map(&:to_s).uniq.sort.last(4)

          headers = ["Project", "Model", "Bedrooms", "Area"] + dates

          grouped_projects = sorted_projects.reduce({}) do |result, item|
            area = sprintf("%.2f", item.area_as_number)
            result[item.project] ||= {}
            result[item.project][item.model] ||= {}
            result[item.project][item.model][item.bedrooms] ||= {}
            result[item.project][item.model][item.bedrooms][area] ||= {}
            result[item.project][item.model][item.bedrooms][area][item.date.to_s] ||= item

            result
          end

          results = []
          pastel = Pastel.new

          grouped_projects.each do |project, by_project|
            by_project.each do |model, by_model|
              by_model.each do |bedrooms, by_bedrooms|
                by_bedrooms.each do |area, by_area|
                  row = [project, model, bedrooms, area]

                  dates.each_with_index do |date, index|
                    item = by_area[date]

                    if item
                      value = "#{item.currency} #{sprintf('%.2f', item.price_as_number)}"
                      if dates[index - 1] && by_area[dates[index - 1]]
                        if by_area[dates[index - 1]].price_as_number > item.price_as_number
                          value = pastel.green(value)
                        elsif by_area[dates[index - 1]].price_as_number < item.price_as_number
                          value = pastel.red(value)
                        end
                      end

                      row << value
                    else
                      row << nil
                    end
                  end

                  results << row
                end
              end
            end
          end

          table = TTY::Table.new(headers, results)
          renderer = TTY::Table::Renderer::ASCII.new(table)

          puts table.render(:ascii, alignments: [:left, :left, :right, :right] + dates.map { :right }, padding: [0, 1])
        end
      end
    end
  end
end