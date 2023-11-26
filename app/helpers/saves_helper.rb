module SavesHelper
  def form_field_for(form, save, field)
    value = save.save_data[field]["value"]
    case save.save_data[field]["__type"]
    when "int"
      form.number_field field.underscore, value: value
    when "bool"
      form.check_box field.underscore, checked: value
    # Add more cases for other data types if needed
    else
      form.text_field field.underscore, value: value
    end
  end
end
