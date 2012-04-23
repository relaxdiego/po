require 'capybara'
require 'capybara/dsl'

module PO

  class Page

    #=====================
    # CLASS METHODS
    #=====================

    def self.path(path)
      send :define_method, :path do
        path
      end
    end

    def self.method_missing(name, *args, &block)
      if name =~ /_(button|field)$/
        register_element name, args[0]
      else
        super name, args, block
      end
    end

    def self.register_element(name, locator)
      if locator.class == Hash && locator.has_key?(:xpath)
        send :define_method, name do
          find_by_xpath locator
        end

        send :define_method, "has_#{ name }?" do
          has_xpath? locator
        end
      else
        send :define_method, name do
          find locator
        end

        send :define_method, "has_#{ name }?" do
          has_css_selector? locator
        end
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
      element_method_call = /^(has_)?(?<name>.+)_(?<type>button|field)\??$/.match(name)
      if element_method_call
        raise_missing_element_declaration_error(element_method_call['name'], element_method_call['type'])
      else
        super name, args, block
      end
    end

    def raise_missing_element_declaration_error(element_name, element_type)
      raise "I don't know how to find #{ element_name }. " +
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