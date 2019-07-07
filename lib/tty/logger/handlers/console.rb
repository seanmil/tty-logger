# frozen_string_literal: true

require "pastel"

module TTY
  class Logger
    module Handlers
      class Console
        STYLES = {
          debug: {
            label: "debug",
            symbol: "•",
            color: :cyan,
            levelpad: 2
          },
          info: {
            label: "info",
            symbol: "ℹ",
            color: :green,
            levelpad: 3
          },
          warn: {
            label: "warning",
            symbol: "⚠",
            color: :yellow,
            levelpad: 0
          },
          error: {
            label: "error",
            symbol: "⨯",
            color: :red,
            levelpad: 2
          },
          fatal: {
            label: "fatal",
            symbol: "!",
            color: :red,
            levelpad: 2
          }
        }

        attr_reader :output

        def initialize(output: $stderr)
          @output = output
          @mutex = Mutex.new
          @pastel = Pastel.new
        end

        # Handle log event output in format
        #
        # @api public
        def call(*message, fields, name: nil)
          @mutex.lock

          style = STYLES[name]
          color = configure_color(style)

          fmt = []
          fmt << color.(style[:symbol])
          fmt << color.(style[:label]) + (" " * style[:levelpad])
          fmt << message.join(" ")
          fmt << fields unless fields.empty?

          output.puts fmt.join(" ")
        ensure
          @mutex.unlock
        end

        def configure_color(style)
          color = style.fetch(:color) { :cyan }
          @pastel.send(color).detach
        end
      end # Console
    end # Handlers
  end # Logger
end # TTY
