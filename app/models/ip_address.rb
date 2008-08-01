class IpAddress < ActiveRecord::Base
  # This model just exists for the acts_as_rated plugin, to provide a rater
  # model.  Usually this is a user, but fractalcomposer.com doesn't have users;
  # instead we allow one rating per fractal piece per ip address.
  
  def self.get(ip_address)
    existing_record = self.find_by_ip_address(ip_address)
    return existing_record if existing_record    
    self.create(:ip_address => ip_address)    
  end
end
