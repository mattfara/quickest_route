defmodule QuickestRouteWeb.InputHelpers do
  use Phoenix.HTML

  def array_add_button(form, field) do
    id = Phoenix.HTML.Form.input_id(form, field) <> "_container"

    data = [
      blueprint: create_li(form, field, value: "") |> safe_to_string,
      container: id
    ]

    link("Add", to: "#", data: data, title: "Add", class: "add-array-item")
  end

  def array_input(form, field) do
    id = Phoenix.HTML.Form.input_id(form, field) <> "_container"
    values = Phoenix.HTML.Form.input_value(form, field) || [""]

    content_tag :ol, id: id, class: "input_container" do
      for {value, i} <- Enum.with_index(values) do
        input_opts = [
          value: value,
          id: nil
        ]

        create_li(form, field, input_opts, index: i)
      end
    end
  end

  def create_li(form, field, input_options \\ [], data \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)
    name = Phoenix.HTML.Form.input_name(form, field) <> "[]"
    opts = Keyword.put_new(input_options, :name, name)

    content_tag :li do
      [
        apply(Phoenix.HTML.Form, type, [form, field, opts]),
        link("Remove", to: "#", data: data, title: "Remove", class: "remove-array-item")
      ]
    end
  end
end
