Then('the CycloneDX file {string} should be valid') do |bom_path|
  unless system("cyclonedx validate --fail-on-errors --input-file #{bom_path}")
    raise "CycloneDX file is not valid: #{bom_path}"
  end
end

Then('the CycloneDX file {string} should contain {string}') do |bom_path, package_url|
  bom_file_lines = bom_path.readlines(bom_path)
  was_package_url_found = false
  bom_file_lines.each do |line|
    if line.include?(package_url)
      was_package_url_found = true
      break
    end
  end
  unless was_package_url_found
    raise "Unable to find #{package_url} in #{bom_path}"
  end
end
