require 'rails/generators'

module Semantic
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      desc "This generator installs Semantic UI to Asset Pipeline"

      def add_assets
        # copy js manifest
        js_manifest = 'app/assets/javascripts/semantic-ui.js'

        if File.exist?(js_manifest)
          puts <<-EOM
          Notice:
            #{js_manifest} exist; skipping
          EOM
        else
          copy_file "semantic-ui.js", "app/assets/javascripts/semantic-ui.js"
        end

        # copy less manifests
        css_manifests = 'app/assets/stylesheets/semantic-ui.css.less'

        if File.exist?(css_manifests)
          puts <<-EOM
          Notice:
            #{css_manifests} exist; skipping
          EOM
        else
          copy_file "semantic-ui", "app/assets/stylesheets/semantic-ui.css.less"
        end

      end
    end
  end

end
