module FileTemplater
	class OptionsHandler
		def initialize(argv)
			@nomodify = false

			# Commands that can only be run once.
			@template = nil
			@binding = nil

			@actions = []

			@parser = OptionParser.new do |o|
				o.banner = "Usage: template [options] [binding arguments]"

				o.separator ""
				o.separator "Specific options:"

				o.on("-t", "--template TEMPLATE",
					 "Load TEMPLATE to insert",
					 "into the current directory") do |t|
					can_only_be_used_once @template, "-t"

					@actions << [:template]
					@template = t
				end

				o.on("-b", "--binding BINDING",
					 "Load BINDING as the binding",
					 "for the loaded template") do |b|
					can_only_be_used_once @binding, "-b"

					@binding = b
				end

				o.on("-a", "--add THING", Array,
					 "Add THING, a template or a binding,",
					 "to the template or binding directory") do |t|
					@actions << [:add, t]
				end

				o.on("-r", "--remove THING", Array,
					 "Removes template or binding THING") do |tb|
					@actions << [:remove, tb]
				end

				o.on("-l", "--list",
					 "Lists the templates and bindings",
					 "that are loaded") do
					@actions << [:list]
				end

				o.on("-m", "--no-modify",
					 "Prevents modifying the template source",
					 "when loading") do
					@nomodify = true
				end

				o.on("-c", "--copy THING", Array,
					 "Copies THING, a template or binding,",
					 "into current directory") do |tb|
					@actions << [:copy, tb]
				end

				o.separator ""
				o.separator "Common options:"

				o.on_tail("-v", "--version", "Display the version") do
					puts "File Templater (template) version " + VERSION
					puts
					puts "Copyright (C) 2015-2016 Sam Craig"
					puts "Licensed under the GNU General Public License version 3."

					exit
				end

				o.on_tail("-h", "--help", "Show this message") do
					puts o

					exit
				end
			end

			if argv.empty?
				puts @parser
				exit
			else
				@parser.parse!(argv)
				@arguments = argv
			end
		end

		def process_actions
			if @actions.empty?
				puts @parser
				puts "\nNo actions were supplied to the program!  The program will not do anything as a result."
				exit
			end

			# All actions should be unique.
			@actions.uniq!

			@actions.each do |a|
				command = a.first
				arguments = a[1]

				case command
				when :template
					# arguments is the template name,
					# @arguments are the extraneous arguments
					template = Template.new(@template, @arguments, nomodify: @nomodify, bind: @binding)
					template.load
				when :add
					arguments.each do |ar|
						FileActions.add(ar)
					end
				when :remove
					arguments.each do |ar|
						FileActions.remove(ar)
					end
				when :list
					puts FileActions.list
				when :copy
					arguments.each do |ar|
						FileActions.copy(ar)
					end
				end
			end
		end

		def can_only_be_used_once(variable, switch)
			if variable
				puts "The #{switch} switch can only be used once!"

				exit
			end
		end
	end
end
