module DocumentsHelper
  def show_document_thumbs(document, version = :mini)
    styles = version == :mini ?
      [:pdf_mini_thumb, :pdf_mini_thumb_2, :pdf_mini_thumb_3] :
      [:pdf_thumb,      :pdf_thumb_2,      :pdf_thumb_3]

    styles.each_with_index.map do |style, i|
      file = document.file.send(style.to_sym)
      if document.file && File.exists?(file.path)
        thumb_image_tag = image_tag(
          file.url, alt: document.name
        )
        image_link = content_tag(
          :a, thumb_image_tag.html_safe, href: '#document_thumbs_modal',
          data: { toggle: 'modal' }
        )

        content_tag :div, image_link.html_safe, class: (i == 0 ? 'item active' : 'item')
      end
    end.compact.join("\n").html_safe
  end

  def show_document_media_field(form)
    media_types = PrintJobType::MEDIA_TYPES.values.map do |mt|
      [show_document_media_text(mt), mt]
    end

    form.input :media, collection: media_types, prompt: true
  end

  def show_document_media_text(media)
    t("view.print_job_types.media_type.#{PrintJobType::MEDIA_TYPES.invert[media]}")
  end

  def show_document_barcode(document)
    barcode = get_barcode_for document
    outputter = barcode.outputter_for(:to_svg)

    outputter.title = document.to_s
    outputter.xdim = outputter.ydim = 3

    raw outputter.to_svg.split("\n")[1..-1].join("\n")
  end

  def document_link_to_barcode(code)
    out = []
    out << link_to(
      t('label.download'), download_barcode_path(code),
      class: 'download_barcode'
    )
    out << link_to(
      t('label.show'), barcode_document_path(code),
      class: 'show_barcode', remote: true, data: { type: 'html' }
    )

    raw out.join(' | ') << content_tag(:div, nil, class: 'barcode_container')
  end

  def document_link_for_use_in_next_print(document)
    content = ''

    if @documents_for_printing.include?(document.id)
      content << link_to(
        '&#xe009;'.html_safe,
        remove_from_next_print_document_path(document),
        title: t('view.documents.remove_from_next_print.title'),
        remote: true, method: :delete, class: 'remove_link iconic'
      )
    else
      content << link_to(
        '&#xe008;'.html_safe,
        add_to_next_print_document_path(document),
        title: t('view.documents.add_to_next_print.title'),
        remote: true, method: :post, class: 'add_link iconic'
      )
    end

    content_tag :span, raw(content),
      id: "document_for_use_in_next_print_#{document.id}"
  end

  def get_barcode_for(document)
    Barby::QrCode.new(
      add_to_order_by_code_catalog_url(
        document.code,
        host: PUBLIC_DOMAIN, port: PUBLIC_PORT, protocol: PUBLIC_PROTOCOL
      ), level: :h
    )
  end

  def document_file_identifier(document)
    document.file.identifier || document.file_identifier if document.file?
  end
end
