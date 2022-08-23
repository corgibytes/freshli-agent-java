require 'fileutils'

Given('I clone the git repository {string} with the sha {string}') do |repository_url, sha|
  repositories_dir = "#{Aruba.config.working_directory}/tmp/repositories"
  cloned_dir = "#{repositories_dir}/#{repository_url.split("/").last}"

  FileUtils.mkdir_p(repositories_dir)

  unless Dir.exists?(cloned_dir)
    $stdout.print "Cloning #{repository_url} ..."
    unless system("git clone #{repository_url}", chdir: repositories_dir, out: "/dev/null", err: "/dev/null")
      raise "Failed to clone #{repository_url}"
    end
    puts "done."
  end
  unless system("git checkout #{sha}", chdir: cloned_dir, out: "/dev/null", err: "/dev/null")
    raise "Failed to checkout #{sha}"
  end
end
