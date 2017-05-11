# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Page.create(link: "http://localhost:3000/", dataset_id: 1)
ServerStep.create(action_name: "Print string", action: "puts 'string'", dataset_id: 1)