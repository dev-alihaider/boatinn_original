# frozen_string_literal: true

class TranslateFaqs < ActiveRecord::Migration[5.1] # :nodoc:
  def change
    reversible do |dir|
      dir.up do
        Faq.create_translation_table!({ title: :string, description: :text },
                                      migrate_data: true,
                                      remove_source_columns: true)
      end

      dir.down { Faq.drop_translation_table!(migrate_data: true) }
    end
  end
end
