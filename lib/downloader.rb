class Downloader
  def self.get(url)
    puts `wget -P ./leaks -q #{url}`
  end
end
