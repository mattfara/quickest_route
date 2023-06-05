defmodule Utils.PipeHelpersTest do
  use ExUnit.Case
  doctest Utils.PipeHelpers
  alias Utils.PipeHelpers

  describe "pipe_or/4" do
    setup do
      {:ok,
       %{
         predicate: fn list -> Enum.all?(list, fn x -> x >= 0 end) end,
         truthy_data: [1, 2, 3],
         falsy_data: [-1, 2, 3],
         true_fn: fn list -> Enum.map(list, fn x -> x * 2 end) end,
         false_fn: fn list -> Enum.map(list, fn x -> x * -2 end) end
       }}
    end

    test "should apply true_fn function for truthy predicate", context do
      assert [2, 4, 6] ==
               PipeHelpers.pipe_or(context.truthy_data, context.predicate, context.true_fn)
    end

    test "should simply return data unchanged if predicate falsy and no false_fn supplied",
         context do
      assert [-1, 2, 3] ==
               PipeHelpers.pipe_or(context.falsy_data, context.predicate, context.true_fn)
    end

    test "should apply false_fn when predicate falsy", context do
      assert [2, -4, -6] ==
               PipeHelpers.pipe_or(
                 context.falsy_data,
                 context.predicate,
                 context.true_fn,
                 context.false_fn
               )
    end
  end
end
