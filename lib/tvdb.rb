#encoding: UTF-8

require 'fileutils'
require 'net/http'
require 'open3'
require 'json'

module TVDB
  class Episode
    
    attr_accessor :id, :number, :title, :description, :season, :show, :date

    def self.parse(data)
      e = Episode.new
      
      %w(id number title description season show).each do |attr|
        e.send("#{attr}=", data[attr])
      end

      e
    end
  end

  class API
    
    def self.get(file)
      # let's try with the web service first...
      e = WWW.get(File.basename(file))

      # didn't work? Let's try AtomicParsley
      e = System.get(file) unless e

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
        info = {}

        _, stdout, _ = Open3.popen3('AtomicParsley', file, '-t')
        parsed = (stdout.gets(nil) || "").scan  /Atom "(.\w+)"\scontains:\s(.+)/
        parsed.each do |name, value|
          info[@@prop[name]] = value if @@prop[name]
        end

        if info['show'] && info['season'] && info['number'] && info['title']
          Episode.parse(info)
        else
          puts "Can't collect information for #{file}"
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
        # first, let's try with the service
        if episode = API.get(file)
          copy(file, episode)
        else
          puts "Can't find episode : #{file}"
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
        puts "Destination file already exists : #{dest}"
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
