# BBC Programmes Tagging Co-Occurrences Demo

## Generating the data 

Data is already available in the files `tag_data.txt` and in a more prepeared form in `sorted_tag_data.rb`

To recreate the data files you need a copy of the BBC Programmes data MySQL DB then
run `gen_tag_pairs.rb`

## Running the app

    brew install memcached
    bundle install
    bundle exec ruby app.rb

    http://localhost:4567/tag/Jeremy_Clarkson

