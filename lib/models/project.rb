require "active_worksheet"

class Project < ActiveWorksheet::Base
  self.source = "~/departamentos.csv"

  def currency
    self.price.split(" ").first
  end

  def price_as_number
    self.price.split(" ").last.gsub(",", "").to_f
  end

  def area_as_number
    self.area.gsub(" m2", "").to_f
  end

  def price_per_m2
    (self.price_as_number / self.area_as_number).round(2)
  end
end