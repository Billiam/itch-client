# frozen_string_literal: true

# Limit output of agent variable
module SimpleInspect
  def inspect
    attrs = pretty_print_instance_variables
    values = [
      "#{self.class}##{object_id}",
      *attrs.map { |k| "#{k}: #{instance_variable_get(k)}" }
    ]

    "<#{values.join(" ")}>"
  end

  def pretty_print_instance_variables
    instance_variables.sort.reject { |i| exclude_inspection.include? i }
  end

  def exclude_inspection
    [:agent]
  end
end
