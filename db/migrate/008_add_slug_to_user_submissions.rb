class UserSubmission < ActiveRecord::Base
  # this logic is copied from UserSubmission so that the slug gets set in our migration...
  before_validation :set_slug

  private

  def expected_id
    self.new_record? ? UserSubmission.find(:first, :order => 'id DESC', :select => 'id').id + 1 : self.id
  end

  def set_slug
    return unless slug.blank?

    new_slug = Slugalizer.slugalize("#{title} by #{name}")

    # we don't prevent duplicate names, so we might wind up with a duplicate slug; in this case use the id as well...
    if UserSubmission.find(:first, :conditions => ['slug = ?', new_slug])
      new_slug = Slugalizer.slugalize("#{title} by #{name} #{expected_id}")
    end

    self.slug = new_slug
  end
end

class AddSlugToUserSubmissions < ActiveRecord::Migration
  def self.up
    # max key length for an index is 767 bytes...
    add_column :user_submissions, :slug, :string, :limit => 1024, :null => false, :default => ''
    
    UserSubmission.find(:all).each do |usub|
      usub.save!
    end
  end

  def self.down
    remove_column :user_submissions, :slug
  end
end
