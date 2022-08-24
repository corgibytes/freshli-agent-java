Then('the CycloneDX file {string} should be valid') do |bom_path|
  unless system("cyclonedx validate --fail-on-errors --input-file #{Aruba.config.working_directory}/#{bom_path}",
                out: '/dev/null', err: '/dev/null')
    raise "CycloneDX file is not valid: #{bom_path}"
  end
end

Then('the CycloneDX file {string} should contain {string}') do |bom_path, package_url|
  bom_file_lines = File.readlines("#{Aruba.config.working_directory}/#{bom_path}")
  was_package_url_found = false
  bom_file_lines.each do |line|
    if line.include?(package_url)
      was_package_url_found = true
      break
    end
  end
  raise "Unable to find #{package_url} in #{bom_path}" unless was_package_url_found
end
