require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
    if(phone_number != nil)
        phone_number.gsub!(/[^\d]/,'')

        if phone_number.length==10
            phone_number
        elsif phone_number.length == 11 && phone_number[0] == "1"
            phone_number[1..10]
        else
            "Wrong Number!!"
        end
    end
 end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def most_frequent_element(array)
    frequency_hash = Hash.new(0)

    array.each do |element|
      frequency_hash[element] += 1
    end
  
    max_frequency_element = frequency_hash.max_by { |_, frequency| frequency }
  
    max_frequency_element.first
  end

def save_thank_you_letter(id,form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')
  
    filename = "output/thanks_#{id}.html"
  
    File.open(filename, 'w') do |file|
      file.puts form_letter
    end
  end

def get_hour(date_string)
  date_time= DateTime.strptime(date_string, "%m/%d/%y %H:%M")
  hour = date_time.hour
end

def get_day(date_string)
    date_time = DateTime.strptime(date_string, "%m/%d/%y %H:%M")
    day = date_time.wday
end

puts 'EventManager initialized.'

reg_hour = []
reg_day = []

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
    id = row[0]
    name = row[:first_name]
    phone = row[:homephone]
    date_string = row[:regdate]
  
    zipcode = clean_zipcode(row[:zipcode])
    phone_number = clean_phone_number(row[:zipcode])
    reg_hour.push(get_hour(date_string))
    reg_day.push(get_day(date_string))
    
    legislators = legislators_by_zipcode(zipcode)
  
    form_letter = erb_template.result(binding)
  
    save_thank_you_letter(id,form_letter)
end


highest_reg_hour = most_frequent_element(reg_hour)
puts "Hour of the day: #{highest_reg_hour}:00"
highest_reg_day = most_frequent_element(reg_day)
puts "Day of the week (integer): #{highest_reg_day}"
puts "Day of the week (string): #{Date::DAYNAMES[highest_reg_day]}"