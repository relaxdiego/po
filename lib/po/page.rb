require 'capybara'
require 'capybara/dsl'

module PO

  class Page

    ELEMENT_TYPES = 'button|field|link|checkbox|form'
    LIST_TYPES    = 'list|dropdown'

    #=====================
    # CLASS METHODS
    #=====================

    def self.path(path)
      send :define_method, :path do
        path
      end
    end

    def self.method_missing(name, *args, &block)
      element = /^(?<name>.+)_(?<type>#{ ELEMENT_TYPES })$/.match(name)
      list    = /^(?<name>.+)_(?<type>#{ LIST_TYPES })$/.match(name)

      if element
        register_element element['name'], element['type'], args[0]
      elsif list
        register_list list['name'], list['type'], args[0]
      else
        super name, args, block
      end
    end

    def self.register_element(name, type, locator)
      if locator.class == Hash && locator.has_key?(:xpath)
        send :define_method, "#{ name }_#{ type }" do |vars = {}|
          locator = locator[:xpath]
          vars.each { |k, v| locator.gsub!("<#{ k }>", v) }
          find_by_xpath locator
        end

        send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
          locator = locator[:xpath]
          vars.each { |k, v| locator.gsub!("<#{ k }>", v) }
          has_xpath? locator
        end
      elsif locator.class == String || (locator.class == Hash && locator.has_key?(:css))
        send :define_method, "#{ name }_#{ type }" do |vars = {}|
          vars.each { |k, v| locator.gsub!("<#{ k }>", v) }
          find locator
        end

        send :define_method, "has_#{ name }_#{ type }?" do |vars = {}|
          vars.each { |k, v| locator.gsub!("<#{ k }>", v) }
          has_css_selector? locator
        end
      else
        raise "Invalid element locator #{ locator.inspect }"
      end
    end

    def self.register_list(name, type, items_locator)
      if items_locator.class == Hash && items_locator.has_key?(:xpath)
        send :define_method, "#{ name }_#{ type }" do
          session.all :xpath, items_locator[:xpath]
        end
      elsif items_locator.class == String
        send :define_method, "#{ name }_#{ type }" do
          session.all :css, items_locator
        end
      else
        raise "Invalid list item locator #{ items_locator.inspect }"
      end

      send :define_method, "has_#{ name }_#{ type }?" do
        send("#{ name }_#{ type }").count > 0
      end
    end

    attr_reader :path

    def initialize
      @session = Capybara.current_session
    end

    #=====================
    # ACTIONS
    #=====================

    def visit
      session.visit path
    end

    def find(selector)
      session.find(selector)
    end

    def find_by_xpath(the_xpath)
      session.find(:xpath, the_xpath)
    end

    #=====================
    # QUERIES
    #=====================

    def has_expected_path?
      expected_path == actual_path
    end

    def has_expected_url?
      expected_url == actual_url
    end

    def has_css_selector?(selector)
      session.has_selector? selector.to_s
    end

    def has_content?(content)
      session.has_content? content
    end

    def has_xpath?(the_xpath)
      session.has_xpath? the_xpath
    end

    #=====================
    # OTHERS
    #=====================

    def expected_path
      path
    end

    def actual_path
      session.current_path
    end

    def expected_url
      "#{ session.current_host }#{ expected_path }"
    end

    def actual_url
      "#{ session.current_host }#{ actual_path }"
    end

    #=====================
    # METHOD MISSING
    #=====================

    def method_missing(name, *args, &block)
      element_query  = /^has_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })\??$/.match(name)
      element_find   = /^(?<name>.+)_(?<type>#{ ELEMENT_TYPES })$/.match(name)
      element_action = /^(?<action>click|fill_in|select|check)_(?<name>.+)_(?<type>#{ ELEMENT_TYPES })/.match(name)

      if element_action
        raise "Undefined method '#{ element_action[0] }'. Maybe you mean " +
              "#{ self.class }##{ element_action['name'] }_#{ element_action['type'] }.#{ element_action['action'] }?"
      elsif element_query
        raise_missing_element_declaration_error(element_query['name'], element_query['type'])
      elsif element_find
        raise_missing_element_declaration_error(element_find['name'], element_find['type'])
      else
        super name, args, block
      end
    end

    def raise_missing_element_declaration_error(element_name, element_type)
      raise "I don't know how to find the #{ element_name } #{ element_type }. " +
            "Make sure you define it by adding '#{ element_name }_#{ element_type } " +
            "<css_selector>' in #{ self.class }"
    end

    #=====================
    # PRIVATE METHODS
    #=====================

    private

    def session
      @session
    end

  end

end