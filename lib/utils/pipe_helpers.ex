defmodule Utils.PipeHelpers do
  @moduledoc """
  Functions to help with pipe operations
  """

  @doc """
  Applies one function to data if a predicate is true, or another if it is false. Default
  false function simply returns data unchanged
  """
  def pipe_or(data, predicate, true_fn, false_fn \\ fn data -> data end)
      when is_function(predicate, 1)
      when is_function(true_fn, 1)
      when is_function(false_fn, 1) do
    if predicate.(data) do
      true_fn.(data)
    else
      false_fn.(data)
    end
  end

  ## TODO - what about something like a
  ## `pipe_if_else`? Different from above?

end
