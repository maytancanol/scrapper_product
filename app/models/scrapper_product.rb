class ScrapperProduct
  include Concurrent::Async
  attr_reader :root, :handler
  @@status = "New"

  def initialize(args = {})
    options = defaults.merge(args)
    # @root = root
    # @handler = handler
    @root = options.fetch(:root)
    @handler = options.fetch(:handler)
    # @options = options
  end

  def defaults
    {
      root: 'test',
      handler:  :process_index
    }
  end

  def process_index(page, data = {})
    page.search('nav.navigation').search('a').each do |ah|
      spider.enqueue(ah.attr('href'), :process_category)
    end
  end

  def process_category(page, data = {})
    page.search('ol.product-items').search('a').each do |ah|
      if !ah.attr('href').nil? &&  ah.attr('href') != '#' && !ah.attr('href').include?('#reviews')
        spider.enqueue(ah.attr('href'), :process_api)
      end
    end
    page.search('div.pages').search('a').each do |ah|
      if !ah.attr('href').nil? && ah.attr('href') != '#' && !ah.attr('href').include?('#reviews')
        spider.enqueue(ah.attr('href'), :process_category)
      end
    end
  end

  def process_api(page, data = {})
    fields = {}
    fields["name"] = page.search('span.base[data-ui-id="page-title-wrapper"]').first.text()
    fields["price"] = page.search("meta[property='product:price:amount']").first['content']
    fields["description"] = page.search('div#description').text()
    information = {}
    page.search('table.additional-attributes').each do |row|
      properties = row.search('th/text()').map {|text| text.to_s}
      value = row.search('td/text()').map {|text| text.to_s}
      information = Hash[properties.zip(value)]
    end
         
    fields["extra_information"] = information
    # p fields
    spider.record data.merge(fields)
  end

  def results(&block)
    spider.results(&block)
  end

  def run
    @@status = "Running"
    rest = []
    results.lazy.each_with_index do |result, i|
      # puts "Hasil-------------"
      # p result["name"]
      # p result["description"]
      # p result["price"]
      # p result["extra_information"]
      # p result["extra_information"].map {|h| h.join ':' }.join '|'
      rest << result
      Product.find_or_create_by(name: result["name"]) do |product|
        product.description = result["description"]
        product.price = result["price"]
        product.extra_information = result["extra_information"].map {|h| h.join ':' }.join '|'
      end
    end
    @@status = "Completed"
    return rest
  end

  def self.status
    @@status
  end

  private

  def spider
    @spider ||= Spider.new(self, @options)
  end
end

