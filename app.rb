require_relative 'lib/pastebin_scrapper'
require_relative 'lib/downloader'

CORE_URL = "http://pastebin.com/"

print `clear`
puts '## PasteBin Scrapper ##'
puts ''

begin
  while true
   leaks = PastebinScrapper.emails
   if leaks.any?
     leaks.each do |id, emails|
       puts "#{CORE_URL}raw/#{id} (#{emails} emails)"
       Downloader.get "#{CORE_URL}raw/#{id}"
     end
   end
  end

rescue Interrupt
  puts ''
  puts 'PasteBin Scrapper interrupted.'
end
