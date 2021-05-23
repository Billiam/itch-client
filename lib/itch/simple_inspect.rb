# frozen_string_literal: true

# Limit output of agent variable
module SimpleInspect
  def inspect
    attrs = instance_variables.reject { |k| k == :@agent }
    values = [
      "#{self.class}##{object_id}",
      "@agent: #{@agent}",
      *attrs.map { |k| "#{k}: #{instance_variable_get(k)}" }
    ]

    "<#{values.join(" ")}>"
  end

  # rubocop:disable all
  def pretty_print(q)
    obj = self

    q.object_address_group(obj) do
      q.seplist(obj.pretty_print_instance_variables, -> { q.text "," }) do |v|
        q.breakable
        v = v.to_s if v.is_a?(Symbol)
        q.text v
        q.text "="
        q.group(1) do
          q.breakable ""
          if v == "@agent"
            q.object_address_group(obj.instance_eval(v)) {}
          else
            q.pp(obj.instance_eval(v))
          end
        end
      end
    end
  end
  # rubocop:enable all
end
