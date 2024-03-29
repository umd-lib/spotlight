# frozen_string_literal: true
# This migration comes from spotlight (originally 20140228131207)
class CreateSpotlightResources < ActiveRecord::Migration[4.2]
  def change
    create_table(:spotlight_resources) do |t|
      t.references :exhibit
      t.string     :type
      t.string     :url
      t.text       :data
      t.datetime   :indexed_at
      t.timestamps
    end
  end
end
