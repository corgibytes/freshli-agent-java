# frozen_string_literal: true

require 'fileutils'

Given('I clone the git repository {string} with the sha {string}') do |repository_url, sha|
  repositories_dir = "#{Aruba.config.working_directory}/tmp/repositories"
  cloned_dir = "#{repositories_dir}/#{repository_url.split('/').last}"

  FileUtils.mkdir_p(repositories_dir)

  unless Dir.exist?(cloned_dir)
    $stdout.print "Cloning #{repository_url} ..."
    unless system("git clone #{repository_url}", chdir: repositories_dir, out: '/dev/null', err: '/dev/null')
      raise "Failed to clone #{repository_url}"
    end

    puts 'done.'
  end
  unless system("git checkout #{sha}", chdir: cloned_dir, out: '/dev/null', err: '/dev/null')
    raise "Failed to checkout #{sha}"
  end
end

Then('running git status should not report any modifications for {string}') do |git_repository_path|
  system("git add .", chdir: git_repository_path, out: '/dev/null', err: '/dev/null')
  unless system('git diff-index --quiet HEAD --', chdir: git_repository_path, out: '/dev/null', err: '/dev/null')
    raise "The working directory is not clean: #{git_repository_path}"
  end
end

