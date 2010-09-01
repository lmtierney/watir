# encoding: utf-8
module Watir
  class TextField < Input

    attributes Watir::TextArea.typed_attributes
    remove_method :type # we want Input#type here, which was overriden by TextArea's attributes

    def self.from(parent, element)
      type = element.attribute(:type)

      if TextFieldLocator::NON_TEXT_TYPES.include?(type)
        raise TypeError, "expected type != #{type} for #{element.inspect}"
      end

      super
    end

    #
    # Clear the element, the type in the given value.
    #

    def set(*args)
      assert_exists
      assert_writable

      @element.clear
      @element.send_keys(*args)
    end
    alias_method :value=, :set

    #
    # Append the given value to the text in the text field.
    #

    def append(*args)
      assert_exists
      assert_writable

      @element.send_keys(*args)
    end

    #
    # Clear the text field.
    #

    def clear
      assert_exists
      @element.clear
    end

    #
    # Returns the text in the text field.
    #

    def value
      # since 'value' is an attribute on input fields, we override this here
      assert_exists
      @element.value
    end

    private

    def locate
      @parent.assert_exists
      TextFieldLocator.new(@parent.wd, @selector, self.class.attribute_list).locate
    end

    def selector_string
      selector = @selector.dup
      selector[:type] = '(any text type)'
      selector[:tag_name] = "input or textarea"
      selector.inspect
    end
  end

  module Container
    def text_field(*args)
      TextField.new(self, extract_selector(args).merge(:tag_name => "input"))
    end

    def text_fields(*args)
      TextFieldCollection.new(self, extract_selector(args).merge(:tag_name => "input"))
    end
  end # Container

  class TextFieldCollection < InputCollection
    private

    def locator_class
      TextFieldLocator
    end

    def element_class
      TextField
    end
  end # TextFieldCollection
end