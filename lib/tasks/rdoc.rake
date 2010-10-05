desc "Generate RDoc"
task :doc => ['doc:generate']

namespace :doc do
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  doc_destination = File.join(project_root, 'doc', 'rdoc')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      yt.files   =  Dir.glob(File.join(project_root, 'lib', '*.rb')) + 
                    Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) +
                    Dir.glob(File.join(project_root, 'vendor','plugins','hydra_repository','lib', '*.rb')) +
                    Dir.glob(File.join(project_root, 'vendor','plugins','hydra_repository','lib','**','*.rb')) +
                    Dir.glob(File.join(project_root, 'vendor','plugins','hydra_repository','app','controllers','*.rb')) +
                    Dir.glob(File.join(project_root, 'vendor','plugins','hydra_repository','app','helpers','*.rb')) +
                    Dir.glob(File.join(project_root, 'vendor','plugins','hydra_repository','app','models','*.rb')) +
                    
                   [ File.join(project_root, 'README.textile') ] +
                   [ File.join(project_root, 'RELEASE_NOTES.textile') ]
                   
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.textile']
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :generate do
      abort "Please install the YARD gem to generate rdoc."
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_dir if File.exists?(doc_destination)
  end

end