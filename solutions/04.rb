class PrivacyFilter
  attr_accessor :preserve_phone_country_code, :preserve_email_hostname, :partially_preserve_email_username

  def initialize(text)
    @filtered_text = text
    @preserve_phone_country_code = false
    @preserve_email_hostname = false
    @partially_preserve_email_username = false
  end

  def filtered
    filter_email
    filter_phone
    @filtered_text
  end

  def filter_email
    @filtered_text.sub!(/([[:alnum:]]([A-Z0-9\-][^-]){0,61}\.)+[A-Z]{2,3}(\.[A-Z]{2})?/i, "Host")
    @filtered_text.sub!(/\b[A-Z0-9][A-Z0-9_+.-]{0,200}@Host/i, "[EMAIL]")
  end

  def filter_phone
    phone = /(0|00|\+[1-9]\d{0,2})(?<phone_number>\d{6,11})/.match @filtered_text
    if phone == nil then return
    elsif preserve_phone_country_code then @filtered_text.sub!(phone[:phone_number], " [FILTERED]")
    else @filtered_text.sub!(/(0|00|\+[1-9]\d{0,2})\d{6,11}/, "[PHONE]")
    end
  end
end

class Validations
  def Validations.email?(value)
    if /^[A-Z0-9][A-Z0-9_+.-]{0,200}@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.match value
      true
    else
      false
    end
  end

  def Validations.hostname?(value)
    if /^([[:alnum:]]([A-Z0-9\-][^-]){0,62}\.)+[A-Z]{2,3}(\.[A-Z]{2})?$/i.match value
      true
    else
      false
    end
  end

  def Validations.phone?(value)
    if /^(0|00|\+[1-9]\d{0,2})\d{6,11}$/.match value
      true
    else
      false
    end
  end

  def Validations.ip_address?(value)
    if /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.match value
      true
    else
      false
    end
  end

  def Validations.number?(value)
    if /^\-?(0|[1-9][0-9]*)(\.[0-9]+)?$/.match value
      true
    else
      false
    end
  end

  def Validations.integer?(value)
    Validations.number?(value)
    if /^\-?(0|[1-9][0-9]*)$/.match value
      true
    else
      false
    end
  end

  def Validations.date?(value)
    if /^\d\d\d\d\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/.match value
      true
    else
      false
    end
  end

  def Validations.time?(value)
    if /^([01][0-9]|2[0-3])(:[0-5][0-9]){2}$/.match value
      true
    else
      false
    end
  end

  def Validations.date_time?(value)
    date_and_separator = /^\d\d\d\d\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])( |T)/.match value
    remaining_text = date_and_separator.post_match unless date_and_separator == nil
    if /^([01][0-9]|2[0-3])(:[0-5][0-9]){2}$/.match remaining_text then true
    else
      false
    end
  end
end
