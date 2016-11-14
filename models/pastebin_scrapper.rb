require 'open-uri'
require 'nokogiri' # https://github.com/sparklemotion/nokogiri

CORE_URL = "http://pastebin.com/"
ID_REGEX = /\A\/[\w]{8}\z/
EMAIL_REGEX = /[\w\-\._]+@[\w\-\_]+\.[a-zA-Z]{2,}/

class PastbinScrapper
  def self.emails
    print "Getting last pastes..."
    paste_ids = PastbinScrapper.get_last_pastes
    puts "ok"

    emails = []
    paste_ids.each_with_index do |paste_id, index|
      print "scanning paste #{index + 1}/#{paste_ids.size}..."
      raw = PastbinScrapper.get_raw(paste_id)
      scanned_email = PastbinScrapper.get_emails(raw)
      if scanned_email.empty?
        puts "no email"
      else
        puts "#{scanned_email.size} emails found at #{CORE_URL}raw#{paste_id}"
      end
      scanned_email.each do |email|
        emails << email
      end
    end

    emails
  end

  def self.get_emails(raw)
    raw.scan(EMAIL_REGEX)
  end

  def self.get_raw(paste_id)
    url = "#{CORE_URL}raw#{paste_id}"
    raw_file = get_html(url)
    return nil unless raw_file
    raw_file.text
  end

  def self.get_last_pastes
    url = "#{CORE_URL}archive"
    html_doc = get_html(url)
    return nil unless html_doc
    pastes = html_doc.search('.maintable a').map do |paste|
      paste_id = paste[:href]
      paste_id if is_id(paste_id)
    end

    pastes.compact
  end

  def self.get_html(url)
    html_file = open(url)
    Nokogiri::HTML(html_file)

  rescue SocketError => error
    puts "#{error.message}.\nVerify your connection... and retry!"
    nil
  end

  def self.is_id(id)
    id =~ ID_REGEX ? true : false
  end
end
