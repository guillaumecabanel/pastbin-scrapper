require 'open-uri'
require 'nokogiri' # https://github.com/sparklemotion/nokogiri

ID_REGEX = /\A[\w]{8}\z/
EMAIL_REGEX = /[\w\-\._]+@[\w\-\_]+\.[a-zA-Z]{2,}/

class PastebinScrapper
  class << self
    def emails
      leaks = {}
      detected_mails = 0
      paste_ids = get_last_pastes

      paste_ids.each_with_index do |paste_id, index|
        # print "scanning paste #{index + 1}/#{paste_ids.size}..."
        raw = get_raw(paste_id)
        scanned_email = get_emails(raw)

        detected_mails += scanned_email.size

        if scanned_email.size > 10
          leaks[paste_id] = scanned_email.size
        end

        print '.'
        print `sleep #{rand(1..5)}`
      end

      puts "| #{detected_mails} mails detected."
      leaks
    end

    def get_emails(raw)
      raw.scan(EMAIL_REGEX)
    end

    def get_raw(paste_id)
      url = "#{CORE_URL}raw/#{paste_id}"
      raw_file = get_html(url)
      return nil unless raw_file
      raw_file.text
    end

    def get_last_pastes
      print "Getting last pastes..."
      url = "#{CORE_URL}archive"
      html_doc = get_html(url)
      return nil unless html_doc
      pastes = html_doc.search('.maintable a').map do |paste|
        paste_id = paste[:href][1..-1] # delete the '/'
        paste_id if is_id(paste_id)
      end

      puts "ok"
      puts '|_________________________|'
      print '|'
      pastes.compact
    end

    def get_html(url)
      html_file = open(url)
      Nokogiri::HTML(html_file)

    rescue SocketError => error
      puts "#{error.message}.\nVerify your connection... and retry!"
      nil
    end

    def is_id(id)
      id =~ ID_REGEX ? true : false
    end
  end
end
