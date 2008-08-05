# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "comments", :force => true do |t|
    t.text     "comment",                        :default => "", :null => false
    t.integer  "commentable_id",                                 :null => false
    t.string   "commentable_type", :limit => 50, :default => "", :null => false
    t.string   "ip_address",                     :default => "", :null => false
    t.string   "name",             :limit => 80, :default => "", :null => false
    t.string   "email",                          :default => "", :null => false
    t.string   "website",                        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generated_pieces", :force => true do |t|
    t.string   "user_ip_address",      :default => "", :null => false
    t.text     "fractal_piece"
    t.string   "generated_midi_file",  :default => "", :null => false
    t.string   "generated_guido_file", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ip_addresses", :force => true do |t|
    t.string   "ip_address", :limit => 20, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ip_addresses", ["ip_address"], :name => "index_ip_addresses_on_ip_address"

  create_table "page_html_parts", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.text     "content"
    t.text     "content_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.integer "rating",     :precision => 10, :scale => 0
  end

  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"
  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_submission_unique_page_views", :force => true do |t|
    t.integer  "user_submission_id",                               :null => false
    t.string   "ip_address",         :limit => 20, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_submission_unique_page_views", ["user_submission_id"], :name => "fk_user_submission_unique_page_views"

  create_table "user_submissions", :force => true do |t|
    t.string   "name",                                                               :default => "",    :null => false
    t.string   "email",                                                              :default => "",    :null => false
    t.boolean  "display_email",        :limit => nil,                                :default => false, :null => false
    t.boolean  "comment_notification", :limit => nil,                                :default => true,  :null => false
    t.string   "website"
    t.string   "title",                                                              :default => "",    :null => false
    t.string   "description"
    t.integer  "generated_piece_id",                                                                    :null => false
    t.datetime "processing_began"
    t.datetime "processing_completed"
    t.string   "piece_mp3_file"
    t.string   "piece_pdf_file"
    t.string   "piece_image_file"
    t.string   "germ_mp3_file"
    t.string   "germ_image_file"
    t.integer  "comment_count",                                                      :default => 0,     :null => false
    t.integer  "total_page_views",                                                   :default => 0,     :null => false
    t.integer  "unique_page_views",                                                  :default => 0,     :null => false
    t.integer  "rating_count"
    t.integer  "rating_total",                        :precision => 10, :scale => 0
    t.decimal  "rating_avg",                          :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_submissions", ["generated_piece_id"], :name => "fk_user_submissions_generated_piece_id_to_generated_pieces"

end
