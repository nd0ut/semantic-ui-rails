require 'rails/generators'

module Semantic
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      desc "This generator installs Semantic UI to Asset Pipeline"

      def add_assets
        # copy js manifest
        js_manifest = 'app/assets/javascripts/semantic-ui.js'
        copy_file "semantic-ui.js", "app/assets/javascripts/semantic-ui.js"

        # copy less manifests
        css_manifests = 'app/assets/stylesheets/semantic-ui.css.less'
        copy_file "semantic-ui.css.less", "app/assets/stylesheets/semantic-ui.css.less"
      end
    end
  end

end
