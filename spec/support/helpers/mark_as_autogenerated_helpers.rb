module MarkAsAutogeneratedHelpers
  def mark_as_auto_generated objects
    Array.wrap(objects)
      .each { |object| object.update_columns auto_generated: true }
      .each { |object| expect(object).to be_auto_generated }
  end
end
