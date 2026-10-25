# frozen_string_literal: true

# Join table between photos and the three fixed home-page carousel tags.
# `created_at` is meaningful: it is when the tag was applied, which drives the
# "most recently tagged" ordering of the home-page wheels.
class CreatePhotoTags < ActiveRecord::Migration[7.0]
  def change
    create_table :photo_tags do |t|
      t.references :photo, null: false, foreign_key: { on_delete: :cascade }
      t.integer :tag, null: false

      t.timestamps
    end

    add_index :photo_tags, %i[photo_id tag], unique: true
    add_index :photo_tags, %i[tag created_at]
  end
end
