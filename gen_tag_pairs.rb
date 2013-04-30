require 'sequel'

DB = Sequel.connect(:adapter => 'mysql2', :user => 'root', :host => 'localhost', :database => 'programmes_search')

available = DB[:pips_tags].map(:pips_programme_id).uniq

$stderr.puts "#{available.count} progs to do"
count = 0

# Then what?
# sort output | uniq -c | sort -r
available.each do |id|

  pairs = DB[:pips_tags].where(:pips_programme_id => id).map(:value).combination(2)

  pairs.each do |(a,b)|
    next if a == b

    if a < b
      puts %Q{<#{a}> <#{b}>}
    else
      puts %Q{<#{b}> <#{a}>}
    end

  end

  $stderr.puts "#{count} of #{available.count} done at #{Time.now}" if count % 100 == 0
  count = count + 1

end
