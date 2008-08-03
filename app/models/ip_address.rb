class IpAddress < ActiveRecord::Base
  # This model just exists for the acts_as_rated plugin, to provide a rater
  # model.  Usually this is a user, but fractalcomposer.com doesn't have users;
  # instead we allow one rating per fractal piece per ip address.
  # In other tables we just store the ip address directly--there's no
  # point in storing the id and doing a join to get the ip address rather
  # than storing it directly...except for the ratings.
  
  def self.get(ip_address)
    return self.find_or_create_by_ip_address(ip_address)
  end
end
