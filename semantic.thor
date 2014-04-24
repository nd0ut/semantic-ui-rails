require 'pry'
require 'fileutils'
require 'git'
require 'logger'
require 'json'

class Semantic < Thor
  include Thor::Actions

  REPO_URI = "https://github.com/Semantic-Org/Semantic-UI.git"

  desc "update", "fetch Semantic UI code from git"
  method_option :branch, default: "css"

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
    fix_paths
    generate_templates
  end

  no_commands do

    def clone
      say_status "STEP", "CLONE REPO"
      Dir.chdir working_dir

      git = Git.clone(REPO_URI, 'semantic-ui')
    end

    def pull
      begin
        say_status "STEP", "PULL REPO"
        git = Git.open(git_root, :log => Logger.new(STDOUT))
        git.pull
      rescue
        puts "no internet connection"
      end
    end

    def parse_version
      say_status "STEP", "PARSE VERSION"
      Dir.chdir git_root

      bower = JSON.parse( IO.read('package.json'), :quirks_mode => true)
      version = bower["version"]

      version_file = source_root + "lib/semantic/ui/rails/version.rb"

      gsub_file version_file, /(?<=VERSION = \")(.+)(?=\")/, version
    end

    def fix_paths
      Dir.glob(source_root + "app" + "**/*.less") do |file|
        gsub_file file, /(?<=url\()(.+\/\w+)(?=\/)/, 'semantic-ui'
        gsub_file file, /(?<= )(url)(?=\()/, 'asset-url'
        gsub_file file, /(?<=asset-url\()(.+)(?=\) |\);)/, '"\\1"'
      end
    end

    def copy_files
      say_status "STEP", "COPY FILES"

      FileUtils.rm_rf(source_root + 'app/assets')

      # STYLESHEETS
      stylesheets_path = "app/assets/stylesheets/semantic-ui/"
      FileUtils.mkdir_p source_root + stylesheets_path
      run "rsync -avm --include='*.less' --include='*.css' -f 'hide,! */' #{git_root + 'src/'} #{source_root + stylesheets_path}"

      # JAVASCRIPTS
      javascripts_path = "app/assets/javascripts/semantic-ui/"
      FileUtils.mkdir_p source_root + javascripts_path
      run "rsync -avm --include='*.js' -f 'hide,! */' #{git_root + 'src/'} #{source_root + javascripts_path}"

      # FONTS
      fonts_path = "app/assets/fonts/semantic-ui/"
      FileUtils.mkdir_p source_root + fonts_path
      run "rsync -avm --include='*.*' -f 'hide,! */' #{git_root + 'src/fonts/'} #{source_root + fonts_path}"

      # IMAGES
      images_path = "app/assets/images/semantic-ui/"
      FileUtils.mkdir_p source_root + images_path
      run "rsync -avm --include='*.*' -f 'hide,! */' #{git_root + 'src/images/'} #{source_root + images_path}"
    end

    def generate_templates
      # JAVASCRIPTS
      say_status "STEP", "GENERATE JAVASCRIPT TEMPLATE"
      js_template_path = source_root + "lib/generators/semantic/install/templates/semantic-ui.js"

      javascripts_path = Pathname.new(source_root + "app/assets/javascripts/semantic-ui")

      FileUtils.rm js_template_path

      File.open(js_template_path, 'a') do |template|
        Dir.glob(source_root + javascripts_path + "**/*") do |file|
          next if File.directory? file

          filepath = Pathname.new(file)

          relative_path = filepath.relative_path_from(javascripts_path)

          template.write "//= require semantic-ui/#{relative_path} \n"
        end
      end

      # STYLESHEETS
      say_status "STEP", "GENERATE STYLESHEETS TEMPLATE"
      css_template_path = source_root + "lib/generators/semantic/install/templates/semantic-ui.css.less"

      stylesheets = Pathname.new(source_root + "app/assets/stylesheets/semantic-ui")

      FileUtils.rm css_template_path

      dirs_order = %w(elements collections views modules)

      File.open(css_template_path, 'a') do |template|
        dirs_order.each do |dir|
          template.write "/* #{dir.capitalize} */ \n"

          file_list = Dir.glob(source_root + stylesheets + dir + "**/*")

          # transition should be last
          file_to_end(file_list, /transition.less/)

          file_list.each do |filepath|
            relative_path = Pathname.new(filepath).relative_path_from(stylesheets)

            template.write "@import 'semantic-ui/#{relative_path}'; \n"
          end

          template.write "\n"
        end
      end
    end

    def file_to_end(file_list, file_regexp)
      found = file_list.grep(file_regexp)
      file = found.first if found

      if file
        file_list.insert(file_list.length - 1, file_list.delete_at(file_list.index(file)))
      end
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
