module FileReset
  def file_reset(file_path, blank_line = false)
    lines = File.readlines(file_path)
    return unless has_commnet_line?(lines)

    filtered_lines = convert_commnet(lines)
    filtered_lines.shift if blank_line

    file_overwrite(file_path, filtered_lines)
  end

  private

  def has_commnet_line?(content)
    content.any? { |line| line.strip.start_with?("#") }
  end

  def convert_commnet(lines)
    lines.reject { |line| line.start_with?("#") }
  end

  def file_overwrite(file_path, content)
    File.open(file_path, "w") do |file|
      file.puts(content)
    end
  end
end
