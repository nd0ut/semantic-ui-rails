require 'pry'
require 'fileutils'
require 'git'
require 'logger'
require 'json'

class Semantic < Thor
  include Thor::Actions


  REPO_URI = "https://github.com/jlukic/Semantic-UI.git"

  desc "update", "fetch Semantic UI code from git"
  def update
    if File.directory? working_dir
      say_status "MESSAGE", "WORKING DIR EXIST"
      pull
    else
      say_status "MESSAGE", "THERE IS NO WORKING DIR"
      prepare
      clone
    end

    parse_version
    copy_files
  end

  no_commands do

    def clone
      say_status "STEP", "CLONE REPO"
      Dir.chdir working_dir

      git = Git.clone(REPO_URI, 'semantic-ui')
    end

    def pull
      say_status "STEP", "PULL REPO"
      git = Git.open(git_root, :log => Logger.new(STDOUT))
      git.pull
    end

    def parse_version
      say_status "STEP", "PARSE VERSION"
      Dir.chdir git_root

      component = JSON.parse( IO.read('component.json'), :quirks_mode => true)
      version = component["version"]

      version_file = source_root + "lib/semantic/ui/rails/version.rb"

      gsub_file version_file, /(?<=VERSION = \")(.+)(?=\")/, version
    end

    def copy_files
      say_status "STEP", "COPY FILES"

      # STYLESHEETS
      stylesheets_path = "vendor/assets/stylesheets/semantic-ui/"
      run "rsync -avm --include='*.less' -f 'hide,! */' #{git_root + 'src/'} #{source_root + stylesheets_path}"

      # JAVASCRIPTS
      javascripts_path = "vendor/assets/javascripts/semantic-ui/"
      run "rsync -avm --include='*.js' -f 'hide,! */' #{git_root + 'src/'} #{source_root + javascripts_path}"

      # FONTS
      fonts_path = "vendor/assets/fonts/semantic-ui"
      run "rsync -avm --include='*.*' -f 'hide,! */' #{git_root + 'src/fonts/'} #{source_root + fonts_path}"

      # IMAGES
      images_path = "vendor/assets/images/semantic-ui/"
      run "rsync -avm --include='*.*' -f 'hide,! */' #{git_root + 'src/images/'} #{source_root + images_path}"
    end

    def clean
      say_status "MESSAGE", "DELETE WORKING DIR"
      FileUtils.rm_rf 'tmp/updater'
    end

    def prepare
      say_status "MESSAGE", "CREATE WORKING DIR"
      FileUtils.mkdir_p 'tmp/updater'
    end


    # dirs

    def self.source_root
      File.dirname(__FILE__)
    end

    def git_root
      working_dir + 'semantic-ui'
    end

    def working_dir
      source_root + 'tmp/updater'
    end

    def source_root
      Pathname.new File.dirname(__FILE__)
    end

  end
end