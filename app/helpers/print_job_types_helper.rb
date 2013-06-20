module PrintJobTypesHelper
  def print_job_types_select_combo(form, form_name = nil)
    collection = PrintJobType.all.map { |pjt| [pjt.name, pjt.id] }

    form.input :print_job_type_id, collection: collection, prompt: false, 
      selected: form.object.print_job_type_id || PrintJobType.default.try(:id), 
      label: false, input_html: {
        class: 'span10 page-modifier price-modifier', name: form_name
      }
  end

  def print_job_types_with_price_for_data
    type_with_price = {}
    PrintJobType.all.each do |pjt|
      type_with_price.merge!({ pjt.id => pjt.price })
    end

    type_with_price.to_json
  end

  def print_job_types_for_data_pages
    types = {}

    PrintJobType.all.each { |pjt| types.merge!({ pjt.id => 0 }) }

    types.to_json
  end

  def show_price_per_copy_title(price)
    [
      t('view.print_job_types.price_per_side'), number_to_currency(price)
    ].join(' ')
  end

  def show_print_job_type_media_field(form)
    media_types = PrintJobType::MEDIA_TYPES.values.map do |mt|
      [show_print_job_type_media_text(mt), mt]
    end

    form.input :media, collection: media_types, prompt: true
  end

  def show_print_job_type_media_text(media)
    t("view.print_job_types.media_type.#{PrintJobType::MEDIA_TYPES.invert[media]}")
  end
end