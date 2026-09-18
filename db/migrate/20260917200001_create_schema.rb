class CreateSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :code_sets do |t|
      t.string  :kind, null: false            # "dx" (ICD-10-CM) or "px" (CPT)
      t.string  :code, null: false
      t.string  :description, null: false
      t.boolean :billable, null: false, default: true   # header categories (E11) are not billable
      t.boolean :em, null: false, default: false        # CPT evaluation-and-management code
      t.string  :keywords, null: false, default: ""     # rules coder vocabulary
      t.timestamps
    end
    add_index :code_sets, [:kind, :code], unique: true

    # ICD-10-CM Excludes1: "NOT CODED HERE" -- the two codes can never be reported together.
    create_table :excludes1_rules do |t|
      t.string :code_a, null: false     # prefix match, e.g. "E11" excludes "E10"
      t.string :code_b, null: false
      t.string :note, null: false
      t.timestamps
    end
    add_index :excludes1_rules, [:code_a, :code_b], unique: true

    create_table :encounters do |t|
      t.string   :patient_ref, null: false
      t.string   :provider, null: false
      t.date     :date_of_service, null: false
      t.text     :note, null: false
      t.string   :status, null: false, default: "new"   # new -> proposed -> finalized
      t.string   :claim_number
      t.datetime :finalized_at
      t.string   :finalized_by
      t.string   :coder_used
      t.timestamps
    end
    add_index :encounters, :status
    add_index :encounters, :claim_number, unique: true

    create_table :code_proposals do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string  :kind, null: false                 # dx | px
      t.string  :code, null: false
      t.string  :description, null: false, default: ""
      t.text    :rationale, null: false, default: ""
      t.text    :evidence, null: false, default: ""    # verbatim quote from the note
      t.boolean :grounded, null: false, default: false # evidence actually appears in the note
      t.integer :confidence, null: false, default: 0   # 0-100
      t.string  :source, null: false                   # rules | gemini-* | human
      t.string  :state, null: false, default: "proposed"   # proposed | accepted | rejected
      t.string  :modifiers, null: false, default: ""    # CPT modifiers, comma separated ("25")
      t.string  :reviewed_by
      t.datetime :reviewed_at
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :code_proposals, [:encounter_id, :kind, :code], unique: true

    # Append-only. Nothing here is ever updated or deleted; the UI derives history from it.
    create_table :events do |t|
      t.references :encounter, null: false, foreign_key: true
      t.string :actor, null: false
      t.string :action, null: false
      t.jsonb  :payload, null: false, default: {}
      t.datetime :created_at, null: false
    end
    add_index :events, [:encounter_id, :created_at]

    create_table :eval_cases do |t|
      t.string :title, null: false
      t.text   :note, null: false
      t.string :gold_dx, array: true, null: false, default: []
      t.string :gold_px, array: true, null: false, default: []
      t.timestamps
    end

    create_table :eval_runs do |t|
      t.string  :coder, null: false
      t.integer :n_cases, null: false
      t.integer :tp, null: false
      t.integer :fp, null: false
      t.integer :fn, null: false
      t.decimal :precision, precision: 5, scale: 4, null: false
      t.decimal :recall, precision: 5, scale: 4, null: false
      t.decimal :f1, precision: 5, scale: 4, null: false
      t.decimal :grounded_pct, precision: 5, scale: 4, null: false
      t.jsonb   :details, null: false, default: []
      t.datetime :ran_at, null: false
      t.timestamps
    end
  end
end
