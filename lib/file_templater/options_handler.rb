module FileTemplater
	class OptionsHandler
		# The actions to do.
		attr_reader :actions
		# The arguments that will be passed to the library.
		attr_reader :arguments

		def initialize(argv)
			@actions = []

			parser = OptionParser.new do |o|
				o.banner = "Usage: template [options]"

				o.separator ""
				o.separator "Specific options:"

				o.on("-t", "--template TEMPLATE",
					 "Load TEMPLATE to insert",
					 "into the current directory") do |t|
					@actions << [:template, t]
				end

				o.on("-a", "--add TEMPLATE", Array,
					 "Add TEMPLATE to the template directory") do |t|
					@actions << [:add, t]
				end

				o.on("-b", "--binding BINDING", Array,
					 "Add BINDING to the binding directory") do |b|
					@actions << [:binding, b]
				end

				o.on("-r", "--remove TEMPLATE", Array,
					 "Removes template or binding TEMPLATE") do |tb|
					@actions << [:remove, tb]
				end

				o.on("-l", "--list",
					 "Lists the templates and bindings",
					 "that are loaded") do
					@actions << [:list]
				end

				o.on("-m", "--no-modify",
					 "Prevents modifying the template source",
					 "when inserting") do
					@actions << [:nomodify]
				end

				o.on("-c", "--copy TEMPLATE", Array,
					 "Copies TEMPLATE and corresponding binding",
					 "into current directory") do |tb|
					@actions << [:copy, tb]
				end

				o.separator ""
				o.separator "Common options:"

				o.on_tail("--verbose", "Run verbosely") do |v|
                    @verbose = true
                end

				o.on_tail("-h", "--help", "Show this message") do
					puts o
					exit
				end
			end

			parser.parse!(argv)
			@arguments = argv
		end

		def process_actions
			@actions.each do |a|
				command = a.first
				# :( no .second in pure Ruby
				arguments = a[1]

				case command
				when :add
					arguments.each do |ar|
						FileActions.add(ar, :template)
					end
				when :binding
					arguments.each do |ar|
						FileActions.add(ar, :binding)
					end
				when :remove
					arguments.each do |ar|
						FileActions.remove(ar)
					end
				when :list
					puts FileActions.list
				end
			end
		end
	end
end
