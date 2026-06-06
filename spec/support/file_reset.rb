# frozen_string_literal: true

module FileReset
  ANNOTATION_BLOCK_PATTERN = %r{^# == AwesomeAnnotate: [^\n]*\n.*?^# == /AwesomeAnnotate: [^\n]*\n(?:\n)*}m

  def file_reset(file_path)
    content = File.read(file_path)
    return unless content.match?(ANNOTATION_BLOCK_PATTERN)

    file_overwrite(file_path, content.gsub(ANNOTATION_BLOCK_PATTERN, ''))
  end

  private

  def file_overwrite(file_path, content)
    File.write(file_path, content)
  end
end
