require 'capybara'
require 'capybara/dsl'

module ActivePage

  class Page

    def self.validates_path(path)
      send :define_method, :path do
        path
      end

      send :define_method, :validate_path do
        session.current_path == self.path
      end
    end

    def self.validates_selector(selector)
      selector = selector.to_s
      send :define_method, "active_page_validate_#{ selector.gsub(/\W/, '_') }" do
        return has_css_selector?(selector), selector
      end
    end

    def self.submit_button_or_link_selector(selector)
      send :define_method, :submit_button_or_link_selector do
        selector
      end
    end

    attr_reader :path
    submit_button_or_link_selector '#submit'

    def initialize
      @session = Capybara.current_session
    end

    #=====================
    # ACTIONS
    #=====================

    def visit
      session.visit path
    end

    def fill_in(field_id, value)
      unless session.has_selector? "##{ field_id.to_s }"
        raise PageAssertionError, "#{ self.class }: Can't find any field with id='#{ field_id }'"
      end
      session.fill_in field_id.to_s, :with => value
    end

    def submit
      unless session.has_selector? "#{ submit_button_or_link_selector }"
        raise PageAssertionError, "#{ self.class }: Can't find a submit button with css selector '#{ submit_button_or_link_selector }'"
      end
      session.find("#{ submit_button_or_link_selector }").click
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

    def is_current?
      session.current_path == self.path
    end

    def is_valid?
      is_current? && missing_selectors.length == 0
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
    # ASSERTIONS
    #=====================

    def should_be_valid
      unless is_valid?
        missing = missing_html_elements

        error = "Expected #{ self.url } but another page was returned."
        error << " URL: #{ session.current_url }." if session.current_url != self.url
        error << " Missing HTML ID#{ missing.length > 1 ? 's' : '' }: " +
                 "#{ missing.join(', ') }" if missing.length > 0

        raise PageAssertionError, error
      end
    end

    def should_be_current
      raise PageAssertionError, "Expected to be redirected to #{ url } but " +
        "was redirected to #{ session.current_url }." unless is_current?
    end

    def should_not_be_current
      raise PageAssertionError, "Expected to NOT be redirected to #{ url }." if is_current?
    end

    def should_have_content(content)
      unless session.has_content?(content)
        raise PageAssertionError, "#{ self.class } does not contain the content '#{ content }'"
      end
    end

    #=====================
    # OTHERS
    #=====================

    def url
      "#{ session.current_host }#{ path }"
    end

    def missing_selectors
      missing = []
      methods.select{ |m| m.to_s =~ /^active_page_validate_.+$/ }.each do |method_name|
        not_missing, selector = send(method_name)
        missing << selector unless not_missing
      end
      missing
    end

    private

    def session
      @session
    end
  end
end