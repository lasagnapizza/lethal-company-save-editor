class Save < ApplicationRecord
  store_accessor :save_data

  MOON_FIELD = %w[CurrentPlanetID]
  GAME_FIELDS = %w[RandomSeed DeadlineTime QuotasPassed]
  MONEY_FIELDS = %w[GroupCredits ProfitQuota QuotaFulfilled]
  PUBLIC_CONSTANT_FIELDS = MOON_FIELD + GAME_FIELDS + MONEY_FIELDS
  PRIVATE_CONSTANT_FIELDS = %w[FileGameVers]
  CONSTANT_FIELDS = PUBLIC_CONSTANT_FIELDS + PRIVATE_CONSTANT_FIELDS

  SHIP_ITEM_IDS = {
    "green_suite" => 1,
    "hazard_suit" => 2,
    "pijama_suit" => 3,
    "cozy_lights" => 4,
    "teleporter" => 5,
    "television" => 6,
    "cupboard" => 7,
    "file_cabinet" => 8,
    "toilet" => 9,
    "shower" => 10,
    "record_player" => 12,
    "table" => 13,
    "romantic_table" => 14,
    "bunkbeds" => 15,
    "loud_horn" => 18,
    "inverse_teleporter" => 19,
    "pumpkin" => 20
  }

  MOON_IDS = {
    "Experimentation" => 0,
    "Assurance" => 1,
    "Vow" => 2,
    "Company Building" => 3,
    "March" => 4,
    "Rend" => 5,
    "Dine" => 6,
    "Offense" => 7,
    "Titan" => 8
  }

  CONSTANT_FIELDS.each do |field|
    define_method(field.underscore) do
      save_data[field]["value"]
    end

    define_method("#{field.underscore}=") do |value|
      save_data[field] ||= {}
      save_data[field]["value"] = value.to_i
    end
  end

  after_initialize :define_dynamic_methods
  after_initialize :set_defaults

  belongs_to :user, optional: true

  before_validation :set_slug

  validates :title, presence: true, length: {maximum: 32}, allow_blank: false
  validates :description, presence: true, length: {maximum: 1000}, allow_blank: true

  def set_slug
    self.slug = title.parameterize
  end

  def current_planet_name
    MOON_IDS.invert[self.current_planet_id]
  end

  def available_ship_items
    SHIP_ITEM_IDS.keys.select { |item_name| self.send(item_name) }.map do |item_name|
      { name: item_name, id: SHIP_ITEM_IDS[item_name] }
    end
  end

  def increament_download_count!
    self.download_count += 1
    self.save
  end

  def save_file
    encrypt_aes(save_data_to_ordered_json, "lcslime14a5")
  end

  def save_data_to_ordered_json
    key_order = [
      "Stats_StepsTaken",
      "Stats_ValueCollected",
      "Stats_Deaths",
      "Stats_DaysSpent",
      "RandomSeed",
      "DeadlineTime",
      "UnlockedShipObjects",
      "ShipUnlockStored_JackOLantern",
      "ShipUnlockStored_Inverse Teleporter",
      "ShipUnlockStored_Loud horn",
      "ShipUnlockStored_Signal transmitter",
      "ShipUnlockStored_Bunkbeds",
      "ShipUnlockStored_Romantic table",
      "ShipUnlockStored_Table",
      "ShipUnlockStored_Record player",
      "ShipUnlockStored_Shower",
      "ShipUnlockStored_Toilet",
      "ShipUnlockStored_File Cabinet",
      "ShipUnlockStored_Cupboard",
      "ShipUnlockStored_Television",
      "ShipUnlockStored_Teleporter",
      "StoryLogs",
      "GroupCredits",
      "CurrentPlanetID",
      "ProfitQuota",
      "QuotasPassed",
      "QuotaFulfilled",
      "FileGameVers"
    ]

    original_data = save_data.dup
    ordered_hash = {}
    key_order.each do |key|
      next unless original_data[key].is_a?(Hash)

      sorted_nested_keys = original_data[key].keys.sort

      ordered_nested_hash = {}
      sorted_nested_keys.each do |nested_key|
        ordered_nested_hash[nested_key] = original_data[key][nested_key]
      end

      ordered_hash[key] = ordered_nested_hash
    end

    ordered_hash.to_json
  end

  private

  def define_dynamic_methods
    SHIP_ITEM_IDS.keys.each do |item|
      self.class.define_method("#{item}") do
        unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
        save_data[unlock_stored_key]&.dig("value")
      end

      self.class.define_method("#{item}=") do |value|
        item_id = SHIP_ITEM_IDS[item]
        if ActiveRecord::Type::Boolean.new.cast(value)
          add_to_unlocked_ship_objects(item_id)
          set_ship_unlock_stored(item, true)
        else
          remove_from_unlocked_ship_objects(item_id)
          remove_ship_unlock_stored(item)
        end
      end
    end
  end

  def set_defaults
    default_data = self.class.default_save_data
    self.save_data = default_data if save_data == {}
  end

  def self.default_save_data
    @default_save_data ||= JSON.parse(File.read(Rails.root.join("config", "defaults", "save_default.json")))
  end

  def add_to_unlocked_ship_objects(item_id)
    unlocked_ship_objects_key = "UnlockedShipObjects"
    save_data[unlocked_ship_objects_key] ||= {"__type" => "System.Int32[],mscorlib", "value" => []}
    save_data[unlocked_ship_objects_key]["value"] << item_id unless save_data[unlocked_ship_objects_key]["value"].include?(item_id)
  end

  def remove_from_unlocked_ship_objects(item_id)
    unlocked_ship_objects_key = "UnlockedShipObjects"
    save_data[unlocked_ship_objects_key]["value"].delete(item_id) if save_data[unlocked_ship_objects_key]&.dig("value")&.include?(item_id)
  end

  def set_ship_unlock_stored(item, value)
    unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
    save_data[unlock_stored_key] = {"__type" => "bool", "value" => value}
  end

  def remove_ship_unlock_stored(item)
    unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
    save_data.delete(unlock_stored_key)
  end

  def encrypt_aes(data, password)
    cipher = OpenSSL::Cipher.new("AES-128-CBC")
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(password, iv, 100, 16, "SHA1")
    cipher.iv = iv
    encrypted_data = cipher.update(data) + cipher.final
    iv + encrypted_data # Append IV to encrypted data
  rescue OpenSSL::Cipher::CipherError => e
    puts "Error encrypting data: #{e.message}"
    nil
  end
end
