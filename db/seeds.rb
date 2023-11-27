Save.create(
  title: "Clean Save v40",
  slug: "clean-save-v40",
  description: "This is a clean save! Nothing fancy, just the default save when you start the game.",
  save_data: JSON.parse(File.read(Rails.root.join("poc/clean_example_3.json")))
)

Save.create(
  title: "Another clean Save v40",
  slug: "another-clean-save-v40",
  description: "Based on the clean save but has more money :) <3",
  save_data: JSON.parse(File.read(Rails.root.join("poc/clean_example.json")))
)
