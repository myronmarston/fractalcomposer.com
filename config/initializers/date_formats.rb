ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
	:nice_datetime => '%-1m/%-1d/%Y %-1I:%M %p',
  # YYYY-MM-DDThh:mm:ssTZD - defined at http://www.w3.org/TR/NOTE-datetime
  # use Datetime.utc.to_s(:w3c_datetime)
  :w3c_datetime => '%Y-%m-%dT%H:%M:%S+00:00'
)
