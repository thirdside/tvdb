#encoding: UTF-8

require 'choice'
require 'cgi'
require 'fileutils'
require 'net/http'
require 'open3'
require 'json'

module TVDB
  
  class Logger
    def self.log message
      $stdout.puts message
    end

    def self.err message
      $stderr.puts message
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
  end

  class API
    
    def self.get(file)
      [AtomicParsley, WWW].each do |klass|
        if e = klass.get(file)
          return e
        end
      end; nil
    end

    class AtomicParsley
      
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
          Logger.err "TVDB::API::AtomicParsley Can't collect enough information for #{file}"
        end
      end
    end

    class WWW
      
      @@url = "http://127.0.0.1:3000"

      def self.get(file)
        fetch("#{@@url}/search/#{CGI.escape(File.basename(file))}.json")
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
            Logger.err "TVDB::API::WWW Can't find episode with #{url}"

            nil
        end
      end
    end
  end

  class App

    def initialize(params)
      @options = params
    end

    def run
      files.each do |file|
        if episode = API.get(file)
          copy(file, episode)
        else
          Logger.err "TVDB::App Can't find episode : #{file}"
        end
      end
    end

    def files
      @files ||= Dir.glob("#{@options[:source]}/**/*.{#{@options[:extensions]}}")
    end

    def copy file, episode
      dest = "#{@options[:destination]}/" << format(episode, File.extname(file), @options[:format])

      # create directories, if they do not exist
      FileUtils.mkpath(File.dirname(dest))

      # link the file
      begin
        FileUtils.link(file, dest)
      rescue Errno::EEXIST
        Logger.err "TVDB::App Destination file already exists : #{dest}"
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

Choice.options do
  header ''
  header 'Specific options:'

  option :source do
    short '-s'
    long '--source=SOURCE'
    desc 'Source folder for all files (default "source")'
    default 'source'
  end

  option :destination do
    short '-d'
    long '--destination=DESTINATION'
    desc 'Destination folder for files (default "TV Shows")'
    default "TV Shows"
  end

  option :extensions do
    short '-e'
    long '--extensions=EXTENSIONS'
    desc 'File extensions (default "avi,mp4,mkv,m4v")'
    default "avi,mp4,mkv,m4v"
  end

  option :format do
    short '-f'
    long '--format=FORMAT'
    desc 'Format episode name (default "%show/%season/%number. %title")'
    default "%show/%season/%number. %title"
  end

  option :delete do
    long '--delete'
    desc 'Delete the original file'
  end
end

TVDB::App.new(Choice).run
