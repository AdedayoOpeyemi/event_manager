require 'csv'

# def clean_zipcode(zipcode)
#     if zipcode.nil?
#       '00000'
#     elsif zipcode.length < 5
#       zipcode.rjust(5, '0')
#     elsif zipcode.length > 5
#       zipcode[0..4]
#     else
#       zipcode
#     end
#   end

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
  end
  
  puts 'EventManager initialized.'
  
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
  
  contents.each do |row|
    name = row[:first_name]
  
    zipcode = clean_zipcode(row[:zipcode])
  
    puts "#{name} #{zipcode}"
  end