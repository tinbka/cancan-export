module CanCan
  module Export
    class Compiler
      
      def initialize
        @mtimes = {}
        @lines = {}
        @js = {}
      end
      
      def to_js(block)
        source_lines = definition(block)
        return @js[source_lines] if @js[source_lines]
        
        case block
        when Proc then source_lines[0] =~ / (?:do|{)\s*(?:\|([\s\w\d,]+)\|)?\s*$/
        when Method then source_lines[0] =~ /def [\w\d\.]+\(?([\s\w\d,]+)\)?\s*$/
        end
        arguments = $1.scan(/\w+/)
        
        coffeefied_source_lines = source_lines[1..-1]*"\n"
        coffeefied_source_lines.gsub!(/\.(\w+)\?/, '.is_\1()') # .present? -> .present()
        coffeefied_source_lines.gsub!(/\.(\w+)!/, '.do_\1()') # .sub! -> .sub!()
        coffeefied_source_lines.gsub!(/(\d+)\.([a-z_]+)/, '(\1).\2()') # 4.hours -> (4).hours()
        coffeefied_source_lines.gsub!(/:([\w\d]+)/, '"\1"') # 4.hours -> (4).hours()
        #$log.info coffeefied_source_lines, caller_at: [0, 9..20]
        
        @js[source_lines] = CoffeeScript.compile "(#{arguments*', '}) ->\n#{coffeefied_source_lines}", bare: true
      end
      
      private
      
      def definition(proc)
        file, line = proc.source_location
        lines = readlines file
        
        definition_line = lines[line-1]
        indentation = definition_line[/^\s*/]
        return lines[line-1..-1].take_while {|line| line !~ /#{indentation}end$/}
      end
      
      def readlines(file)
        if File.exists?(file)
          mtime = File.mtime(file)
          unless @mtimes[file] and @mtimes[file] >= mtime
            @mtimes[file] = mtime
            @lines[file] = IO.readlines(file)
          end
          @lines[file]
        else
          raise Errno::ENOENT, "The file where a block was defined, does not exist anymore @ rb_sysopen - #{file}"
        end
      end
      
    end
  end
end