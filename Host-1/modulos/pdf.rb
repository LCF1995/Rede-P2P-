require 'pdf/reader'
module PdfConverter
	def extract_text(filename)
	  @amount = nil
	  @dataframe = nil
	  @array = nil
	  @count = nil
	  if filename != nil
		PDF::Reader.open("./file/#{filename}.pdf") do |reader|
	    puts "Convertendo para PDF: #{filename}"
	    cont = 0
	    txt = reader.pages.map do |page| 
	      cont += 1
	      begin
	        puts "Convertendo página #{cont}/#{reader.page_count}\r"
	        page.text
	      rescue
	        puts "Página #{pageno}/#{reader.page_count} falha na conversão!!!"
	      end
	    end # pages map
	    puts "\nExcrito em texto..."
	    @dataframe = txt.join("\n")
	    @amount = @dataframe.size
	    @array =  @dataframe.split('')
	    @count  =  @array.size
	    end
	    return @count
	   else
	   	return nil
	   end
	end
end