# frozen_string_literal: true

module AwesomeAnnotate
  module AnnotationBlock
    private

    def replace_or_insert_annotation(file_path:, marker:, content:, before:)
      path = file_path.to_s
      file_content = File.read(path)
      annotation = annotation_block(marker, content)
      pattern = annotation_block_pattern(marker)

      updated_content =
        if file_content.match?(pattern)
          file_content.sub(pattern, annotation)
        else
          file_content.sub(before, "#{annotation}\\0")
        end

      File.write(path, updated_content)
    end

    def annotation_block(marker, content)
      body = content.end_with?("\n") ? content : "#{content}\n"

      "# == AwesomeAnnotate: #{marker}\n" \
        "#{body}" \
        "# == /AwesomeAnnotate: #{marker}\n"
    end

    def annotation_block_pattern(marker)
      escaped_marker = Regexp.escape(marker)
      /^# == AwesomeAnnotate: #{escaped_marker}\n.*?^# == \/AwesomeAnnotate: #{escaped_marker}\n/m
    end
  end
end
