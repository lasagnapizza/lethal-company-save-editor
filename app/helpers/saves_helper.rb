module SavesHelper
  def form_field_for(form, save, field)
    form.text_field field.underscore, value: save.save_data[field]["value"]
  end
end
