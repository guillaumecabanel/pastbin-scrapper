class Downloader
  def self.get(url)
    print `wget -P ./leaks -q #{url}`
  end
end
