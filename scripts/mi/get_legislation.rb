#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'rbutils', 'legislation')

module Michigan
  include Scrapable
  
  def self.state
    'mi'
  end
  
  class Bill    
    def initialize(xml)
      @data = xml
    end
    
    def name
      @title ||= @data.at('title').inner_text
    end
    
    def year
      @title.match(/[0-9]+$/).to_s
    end
    
    def bill_id
      @title.match(/[0-9]+$/).to_s
    end
    
    #TODO do we need to know the session for Michigan?
    def session
    end
    
    #TODO fix me
    def year_range
      "2009-2010"
    end
    
    def chamber
      @title.inner_text =~ /^h/i ? 'lower' : 'upper'
    end
    
    def chamber_name
      chamber && chamber == 'upper' ? 'Senate' : 'House'
    end
    
    def date
      Date.parse(@data.at('pubDate').inner_text)
    end
    
    def remote_url
      normalize_detail_url(@data.at('link').inner_text)
    end
    
    def to_hash
      {
        :bill_state => 'ms',
        :bill_chamber => chamber,
        # :bill_session => session,
        :bill_id => bill_id,
        :bill_name => name,
        :remote_url => remote_url.to_s
      }
    end
    
    private
      def normalize_detail_url(url)
        can = "http://www.legislature.mi.gov/documents/#{year_range}/#{version}/#{chamber_name}/htm/2009-HIB-4691.htm"
        path = "#{@year}/pdf/#{url.strip.split('../').last}"
        URI.parse('http://billstatus.ls.state.ms.us') + path
      end
      
      def normalize_version_url(url)
        path = url.split('objectname=').last   
        can = "http://www.legislature.mi.gov/documents/#{year_range}/#{version}/#{chamber_name}/htm/#{path}.htm"
        
        path = url.strip.split('../').last
        URI.parse('http://billstatus.ls.state.ms.us') + path
      end
  end
  
  BASE_PATH = "http://www.legislature.mi.gov"
  CRAZY_KEY = "(S(xry0x3exnwgonk45kkgxfna4))"

  RECENT_ACTIVITY_PATH = "mileg.aspx?page=BillRecentActivity"
  DAILY_PATH = "mileg.aspx?page=Daily"
   
  ALL_DAILY = [BASE_PATH, CRAZY_KEY, DAILY_PATH].join('/')
  
  FOURSEVEN = 'mileg.aspx?page=getObject&objectname=2009-HB-4757'
  XML_PATH = 'documents/publications/RssFeeds/billupdate.xml'
  #2009-SB-0380
  
  "http://www.legislature.mi.gov/documents/2009-2010/billengrossed/House/htm/2009-HEBS-4397.htm"
  "http://www.legislature.mi.gov/(S(dxj2yq55vncajkifbxhq2k55))/mileg.aspx?page=BillStatus&objectname=2009-HB-4691"
  
  def self.scrape_bills()
    doc = Hpricot.XML(open([BASE_PATH, XML_PATH].join('/')))
    (doc/:item).each do |item|
      chamber = (item/:title) =~ /^h/i ? 'lower' : 'upper'
      Bill.new(item, 2009, )
      title = (item/:title).inner_html
      link = (item/:guid).inner_html
      date = (item/:pubDate).inner_html
      puts [title, link, date].join(', ')
    end
  end
  
  def to_hash
    { :bill_state => 'mi',
      :bill_chamber => chamber,
      :bill_session => @session,
      # :bill_id => bill_id,
      :bill_name => name,
      :remote_url => remote_url.to_s }
  end
  
end

Michigan.scrape_bills