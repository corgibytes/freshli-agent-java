# frozen_string_literal: true

Then('the CycloneDX file {string} should be valid') do |bom_path|
  full_bom_path = Platform.normalize_file_separators("#{Aruba.config.working_directory}/#{bom_path}")
  unless system("cyclonedx validate --fail-on-errors --input-file #{full_bom_path}",
                out: Platform.null_output_target, err: Platform.null_output_target)
    raise "CycloneDX file is not valid: #{bom_path}"
  end
end

Then('the CycloneDX file {string} should contain {string}') do |bom_path, package_url|
  full_bom_path = Platform.normalize_file_separators("#{Aruba.config.working_directory}/#{bom_path}")
  bom_file_lines = File.readlines(full_bom_path)
  was_package_url_found = false
  bom_file_lines.each do |line|
    if line.include?(package_url)
      was_package_url_found = true
      break
    end
  end
  raise "Unable to find #{package_url} in #{bom_path}" unless was_package_url_found
end
