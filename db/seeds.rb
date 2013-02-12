# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Show.create([{
  title: "Dexter",
  seasons: [
    Season.new(
      number: 1,
      episodes: [
        Episode.new(
          number: 1,
          title: "From time to time"
        )]
    )]
}])