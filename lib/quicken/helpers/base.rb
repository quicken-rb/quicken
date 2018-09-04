# frozen_string_literal: true

# This is a porting of Thor::Shell::Basic
# rewritten as a module that can be included by
# plugins

# Thor is available under MIT license
# Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
module Quicken
  module Helpers
    module Base
      # Say (print) something to the user. If the sentence ends with a whitespace
      # or tab character, a new line is not appended (print + flush). Otherwise
      # are passed straight to puts (behavior got from Highline).
      #
      # ==== Example
      # say("I know you knew that.")
      #
      def say message = '', color = nil, force_new_line = (message.to_s !~ /( |\t)\Z/)
        buffer = prepare_message(message, *color)
        buffer << "\n" if force_new_line && !message.to_s.end_with?("\n")

        stdout.print(buffer)
        stdout.flush
      end

      # Asks something to the user and receives a response.
      #
      # If a default value is specified it will be presented to the user
      # and allows them to select that value with an empty response. This
      # option is ignored when limited answers are supplied.
      #
      # If asked to limit the correct responses, you can pass in an
      # array of acceptable answers.  If one of those is not supplied,
      # they will be shown a message stating that one of those answers
      # must be given and re-asked the question.
      #
      # If asking for sensitive information, the :echo option can be set
      # to false to mask user input from $stdin.
      #
      # If the required input is a path, then set the path option to
      # true. This will enable tab completion for file paths relative
      # to the current working directory on systems that support
      # Readline.
      #
      # ==== Example
      # ask("What is your name?")
      #
      # ask("What is the planet furthest from the sun?", :default => "Pluto")
      #
      # ask("What is your favorite Neopolitan flavor?", :limited_to => ["strawberry", "chocolate", "vanilla"])
      #
      # ask("What is your password?", :echo => false)
      #
      # ask("Where should the file be saved?", :path => true)
      #
      def ask statement, *args
        options = args.last.is_a?(Hash) ? args.pop : {}
        color = args.first

        if options[:limited_to]
          ask_filtered(statement, color, options)
        else
          ask_simply(statement, color, options)
        end
      end

      # Say a status with the given color and appends the message. Since this
      # method is used frequently by actions, it allows nil or false to be given
      # in log_status, avoiding the message from being shown. If a Symbol is
      # given in log_status, it's used as the color.
      #
      def say_status status, message, log_status = true
        return if quiet? || log_status == false
        spaces = '  ' * (padding + 1)
        color = log_status.is_a?(Symbol) ? log_status : :green

        status = status.to_s.rjust(12)
        status = set_color status, color, true if color

        buffer = "#{status}#{spaces}#{message}"
        buffer = "#{buffer}\n" unless buffer.end_with?("\n")

        stdout.print(buffer)
        stdout.flush
      end

      # Make a question the to user and returns true if the user replies "y" or
      # "yes".
      #
      def yes? statement, color = nil
        (ask(statement, color, add_to_history: false) =~ is?(:yes))
      end

      # Make a question the to user and returns true if the user replies "n" or
      # "no".
      #
      def no? statement, color = nil
        (ask(statement, color, add_to_history: false) =~ is?(:no))
      end

      # Prints values in columns
      #
      # ==== Parameters
      # Array[String, String, ...]
      #
      def print_in_columns array
        return if array.empty?
        colwidth = (array.map { |el| el.to_s.size }.max || 0) + 2
        array.each_with_index do |value, index|
          # Don't output trailing spaces when printing the last column
          if ((((index + 1) % (terminal_width / colwidth))).zero? && !index.zero?) || index + 1 == array.length
            stdout.puts value
          else
            stdout.printf("%-#{colwidth}s", value)
          end
        end
      end

      protected

      def prepare_message message, *color
        spaces = '  ' * padding
        spaces + set_color(message.to_s, *color)
      end

      # Thor::Shell::Color is available under MIT license
      # Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
      # Embed in a String to clear all previous ANSI sequences.
      CLEAR = "\e[0m"
      # The start of an ANSI bold sequence.
      BOLD = "\e[1m"

      # Set the terminal's foreground ANSI color to black.
      BLACK = "\e[30m"
      # Set the terminal's foreground ANSI color to red.
      RED = "\e[31m"
      # Set the terminal's foreground ANSI color to green.
      GREEN = "\e[32m"
      # Set the terminal's foreground ANSI color to yellow.
      YELLOW = "\e[33m"
      # Set the terminal's foreground ANSI color to blue.
      BLUE = "\e[34m"
      # Set the terminal's foreground ANSI color to magenta.
      MAGENTA = "\e[35m"
      # Set the terminal's foreground ANSI color to cyan.
      CYAN = "\e[36m"
      # Set the terminal's foreground ANSI color to white.
      WHITE = "\e[37m"

      # Set the terminal's background ANSI color to black.
      ON_BLACK = "\e[40m"
      # Set the terminal's background ANSI color to red.
      ON_RED = "\e[41m"
      # Set the terminal's background ANSI color to green.
      ON_GREEN = "\e[42m"
      # Set the terminal's background ANSI color to yellow.
      ON_YELLOW = "\e[43m"
      # Set the terminal's background ANSI color to blue.
      ON_BLUE = "\e[44m"
      # Set the terminal's background ANSI color to magenta.
      ON_MAGENTA = "\e[45m"
      # Set the terminal's background ANSI color to cyan.
      ON_CYAN = "\e[46m"
      # Set the terminal's background ANSI color to white.
      ON_WHITE = "\e[47m"

      # Set color by using a string or one of the defined constants. If a third
      # option is set to true, it also adds bold to the string. This is based
      # on Highline implementation and it automatically appends CLEAR to the end
      # of the returned String.
      #
      # Pass foreground, background and bold options to this method as
      # symbols.
      #
      # Example:
      #
      #   set_color "Hi!", :red, :on_white, :bold
      #
      # The available colors are:
      #
      #   :bold
      #   :black
      #   :red
      #   :green
      #   :yellow
      #   :blue
      #   :magenta
      #   :cyan
      #   :white
      #   :on_black
      #   :on_red
      #   :on_green
      #   :on_yellow
      #   :on_blue
      #   :on_magenta
      #   :on_cyan
      #   :on_white
      def set_color string, *colors
        if colors.compact.empty? || !can_display_colors?
          string
        elsif colors.all? { |color| color.is_a?(Symbol) || color.is_a?(String) }
          ansi_colors = colors.map { |color| lookup_color(color) }
          "#{ansi_colors.join}#{string}#{CLEAR}"
        else
          # The old API was `set_color(color, bold=boolean)`. We
          # continue to support the old API because you should never
          # break old APIs unnecessarily :P
          foreground, bold = colors
          foreground = self.class.const_get(foreground.to_s.upcase) if foreground.is_a?(Symbol)

          bold = bold ? BOLD : ''
          "#{bold}#{foreground}#{string}#{CLEAR}"
        end
      end

      def lookup_color(color)
        return color unless color.is_a?(Symbol)
        self.class.const_get(color.to_s.upcase)
      end

      def can_display_colors?
        stdout.tty?
      end

      # Overwrite show_diff to show diff with colors if Diff::LCS is
      # available.
      #
      def show_diff destination, content
        if diff_lcs_loaded? && ENV['THOR_DIFF'].nil? && ENV['RAILS_DIFF'].nil?
          actual = File.binread(destination).to_s.split("\n")
          content = content.to_s.split("\n")

          Diff::LCS.sdiff(actual, content).each do |diff|
            output_diff_line(diff)
          end
        else
          diff_cmd = ENV["THOR_DIFF"] || ENV["RAILS_DIFF"] || "diff -u"

          require "tempfile"
          Tempfile.open(File.basename(destination), File.dirname(destination)) do |temp|
            temp.write content
            temp.rewind
            system %(#{diff_cmd} "#{destination}" "#{temp.path}")
          end
        end
      end

      def output_diff_line diff
        case diff.action
        when '-'
          say "- #{diff.old_element.chomp}", :red, true
        when '+'
          say "+ #{diff.new_element.chomp}", :green, true
        when '!'
          say "- #{diff.old_element.chomp}", :red, true
          say "+ #{diff.new_element.chomp}", :green, true
        else
          say "  #{diff.old_element.chomp}", nil, true
        end
      end

      # Check if Diff::LCS is loaded. If it is, use it to create pretty output
      # for diff.
      #
      def diff_lcs_loaded? #:nodoc:
        return true if defined?(Diff::LCS)
        return @diff_lcs_loaded unless @diff_lcs_loaded.nil?

        @diff_lcs_loaded = begin
          require 'diff/lcs'
          true
        rescue LoadError
          false
        end
      end

      def stdout
        $stdout
      end

      def stderr
        $stderr
      end

      def is? value #:nodoc:
        value = value.to_s

        if value.size == 1
          /\A#{value}\z/i
        else
          /\A(#{value}|#{value[0, 1]})\z/i
        end
      end

      def ask_simply statement, color, options
        default = options[:default]
        message = [statement, ("(#{default})" if default), nil].uniq.join(' ')
        message = prepare_message(message, *color)
        result = Thor::LineEditor.readline(message, options)

        return unless result

        result = result.strip

        if default && result == ''
          default
        else
          result
        end
      end

      def ask_filtered statement, color, options
        answer_set = options[:limited_to]
        correct_answer = nil
        until correct_answer
          answers = answer_set.join(', ')
          answer = ask_simply("#{statement} [#{answers}]", color, options)
          correct_answer = answer_set.include?(answer) ? answer : nil
          say("Your response must be one of: [#{answers}]. Please try again.") unless correct_answer
        end
        correct_answer
      end

      def die message
        abort "ABORT: #{message}"
      end
    end
  end
end
