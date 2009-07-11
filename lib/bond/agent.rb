module Bond
  class Agent
    def initialize(options={})
      raise ArgumentError unless options[:readline_plugin].is_a?(Module)
      extend(options[:readline_plugin])
      @default_mission_action = options[:default_mission] if options[:default_mission]
      setup
      @missions = []
    end

    def complete(options={}, &block)
      @missions << Mission.new(options.merge(:action=>block))
    end

    def call(input)
      find_mission(input).execute
    rescue
      # p $!
      # p $!.backtrace.slice(0,5)
      default_mission.execute(input)
    end

    def find_mission(input)
      all_input = line_buffer
      @missions.find {|mission| mission.matches?(all_input) } || raise("calling default mission")
    end

    def default_mission
      Mission.new(:action=>default_mission_action, :default=>true)
    end

    def default_mission_action
      @default_mission_action ||= Object.const_defined?(:IRB) ? IRB::InputCompletor::CompletionProc : lambda {|e| [] }
    end
  end
end