# frozen_string_literal: true

module AwesomeAnnotate
  module AnnotationBlock
    private

    def replace_or_insert_annotation(file_path:, marker:, content:, before:)
      path = file_path.to_s
      file_content = File.read(path)
      annotation = annotation_block(marker, content)

      File.write(path, replace_annotation(file_content, marker, annotation, before))
    end

    def remove_annotation(file_path:, marker:)
      path = file_path.to_s
      file_content = File.read(path)
      pattern = annotation_block_pattern(marker)

      return false unless file_content.match?(pattern)

      File.write(path, file_content.gsub(pattern, ''))
      true
    end

    def annotation_block(marker, content)
      body = content.end_with?("\n") ? content : "#{content}\n"

      "# == AwesomeAnnotate: #{marker}\n" \
        "#{body}" \
        "# == /AwesomeAnnotate: #{marker}\n"
    end

    def annotation_block_pattern(marker)
      escaped_marker = Regexp.escape(marker)
      %r{^# == AwesomeAnnotate: #{escaped_marker}\n.*?^# == /AwesomeAnnotate: #{escaped_marker}\n}m
    end

    def replace_annotation(file_content, marker, annotation, before)
      pattern = annotation_block_pattern(marker)

      return file_content.sub(pattern, annotation) if file_content.match?(pattern)

      file_content.sub(before, "#{annotation}\\0")
    end
  end
end
