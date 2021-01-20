class Spider

  attr_reader :handlers

  def initialize(processor, options = {})
    @processor = processor

    @results  = []
    @urls     = []
    @handlers = {}

    enqueue(@processor.root, @processor.handler)
  end

  def enqueue(url, method, data = {})
    return if @handlers[url]
    @urls << url
    @handlers[url] ||= { method: method, data: data }
  end

  def record(data = {})
    @results << data
  end

  def results
    return enum_for(:results) unless block_given?

    i = @results.length
    enqueued_urls.each do |url, handler|
      begin
        log "Handling", url.inspect
        @processor.send(handler[:method], agent.get(url), handler[:data])
        if block_given? && @results.length > i
          yield @results.last
          i += 1
        end
      rescue => ex
        log "Error", "#{url.inspect}, #{ex}"
      end
      #sleep @interval if @interval > 0
    end
  end

  private

  def enqueued_urls
    Enumerator.new do |y|
      index = 0
      while index < @urls.count
        url = @urls[index]
        index += 1
        next unless url
        y.yield url, @handlers[url]
      end
    end
  end

  def log(label, info)
    warn "%-10s: %s" % [label, info]
  end

  def agent
    @agent ||= Mechanize.new
  end
end
