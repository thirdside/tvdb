#encoding: UTF-8

require 'fileutils'
require 'net/http'
require 'open3'
require 'json'

module TVDB
  class Logger
    def log message
      puts message
    end
  end

  class Episode
    
    attr_accessor :id, :number, :title, :description, :season, :show, :date

    def self.parse(data)
      e = Episode.new
      
      %w(id number title description season show).each do |attr|
        e.send("#{attr}=", data[attr])
      end

      e
    end

    def initialize
      Logger.log "New episode created"
    end
  end

  class API
    
    def self.get(file)
      e = nil

      # Let's try AtomicParsley
      e = System.get(file)

      # didn't work? let's try with the web service first...
      e = WWW.get(File.basename(file)) unless e

      # return the episode
      e
    end

    class System
      
      @@prop = {
        "©nam" => 'title',
        "©dat" => 'date',
        "tvsh" => 'show',
        "tvsn" => 'season',
        "tven" => 'number',
        "desc" => 'description',
        "stik" => 'type'
      }

      def self.get(file)
        Logger.log "TVDB::API::System #{info}"

        info = {}

        _, stdout, _ = Open3.popen3('AtomicParsley', file, '-t')
        parsed = (stdout.gets(nil) || "").scan  /Atom "(.\w+)"\scontains:\s(.+)/
        parsed.each do |name, value|
          info[@@prop[name]] = value if @@prop[name]
        end

        if info['show'] && info['season'] && info['number'] && info['title']
          Logger.log "TVDB::API::System enough info, let's create an episode!"

          Episode.parse(info)
        else
          Logger.log "TVDB::API::System can't collect enough information for #{file}"
        end
      end
    end

    class WWW
      
      @@url = "http://127.0.0.1:3000"

      def self.get(query)
        fetch("#{@@url}/search/#{query.gsub(" ", "%20")}.json")
      end

      protected

      def self.fetch(url)
        response = Net::HTTP.get_response(URI(url))

        Logger.log "TVDB::API::WWW Response is #{response}"

        case response
          when Net::HTTPSuccess then
            Episode.parse(JSON.parse(response.body))
          when Net::HTTPRedirection then
            fetch(response['location'])
          else
            nil
        end
      end
    end
  end

  class App

    def initialize(*params)
      @options = {
        :source           => params[0] || ".",
        :destination      => params[1] || "destination",
        :extensions       => %w(avi mp4 mkv m4v),
        :format           => "%show/%season/%number. %title",
        :delete_original  => false
      }
    end

    def run
      files.each do |file|
        Logger.log "Working on #{file}"

        # first, let's try with the service
        if episode = API.get(file)
          copy(file, episode)
        else
          Logger.log "Can't find episode : #{file}"
        end
      end
    end

    def files
      @files ||= Dir.glob("**/*.{#{@options[:extensions].join(',')}}")
    end

    def copy file, episode
      dest = "#{@options[:destination]}/" << format(episode, File.extname(file), @options[:format])

      # create directories, if they do not exist
      FileUtils.mkpath(File.dirname(dest))

      # link the file
      begin
        FileUtils.link(file, dest)
      rescue Errno::EEXIST
        Logger.log "Destination file already exists : #{dest}"
      end

      # delete the original file if required
      FileUtils.remove(file) if @options[:delete_original]
    end

    def format episode, ext, format
      format.gsub(/%show|%season|%number|%title/).each do |match|
        episode.send(match[1..-1])
      end << ext
    end

  end
end

TVDB::App.new(ARGV).run
