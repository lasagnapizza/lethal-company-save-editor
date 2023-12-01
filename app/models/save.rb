class Save < ApplicationRecord
  store_accessor :save_data

  MOON_FIELD = %w[CurrentPlanetID]
  GAME_FIELDS = %w[RandomSeed DeadlineTime QuotasPassed]
  MONEY_FIELDS = %w[GroupCredits ProfitQuota QuotaFulfilled]
  PUBLIC_CONSTANT_FIELDS = MOON_FIELD + GAME_FIELDS + MONEY_FIELDS
  PRIVATE_CONSTANT_FIELDS = %w[FileGameVers]
  CONSTANT_FIELDS = PUBLIC_CONSTANT_FIELDS + PRIVATE_CONSTANT_FIELDS

  SHIP_ITEM_IDS = {
    "green_suit" => 1,
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

  STORY_LOG_IDS = {
    "first_log" => 0,
    "smells_here" => 1,
    "swing_of_things" => 2,
    "golden_planet" => 3,
    "shady" => 4,
    "sound_behind_the_wall" => 5,
    "goodbye" => 6,
    "screams" => 7,
    "idea" => 8,
    "nonsense" => 9,
    "hiding" => 10,
    "desmond" => 11
  }

  ENEMY_SCAN_IDS = {
    "beast_1" => 1,
    "beast_2" => 2,
    "beast_3" => 3,
    "beast_4" => 4,
    "beast_5" => 5,
    "beast_6" => 6,
    "beast_7" => 7,
    "beast_8" => 8,
    "beast_9" => 9,
    "beast_10" => 10,
    "beast_11" => 11,
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

  SHIP_ITEM_IDS.keys.each do |item|
    define_method(item.to_s) do
      unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
      save_data[unlock_stored_key]&.dig("value")
    end

    define_method("#{item}=") do |value|
      item_id = SHIP_ITEM_IDS[item]
      collection = "UnlockedShipObjects"
      if ActiveRecord::Type::Boolean.new.cast(value)
        add_id_to_collection(collection, item_id)
        set_ship_unlock_stored(item, true)
      else
        remove_id_from_collection(collection, item_id)
        remove_ship_unlock_stored(item)
      end
    end
  end

  STORY_LOG_IDS.keys.each do |thing|
    define_method(thing.to_s) do
      collection = "StoryLogs"
      save_data[collection]&.dig("value")&.include?(STORY_LOG_IDS[thing])
    end

    define_method("#{thing}=") do |value|
      thing_id = STORY_LOG_IDS[thing]
      collection = "StoryLogs"
      if ActiveRecord::Type::Boolean.new.cast(value)
        add_id_to_collection(collection, thing_id)
      else
        remove_id_from_collection(collection, thing_id)
      end
    end
  end

  ENEMY_SCAN_IDS.keys.each do |thing|
    define_method(thing.to_s) do
      collection = "EnemyScans"
      save_data[collection]&.dig("value")&.include?(ENEMY_SCAN_IDS[thing])
    end

    define_method("#{thing}=") do |value|
      thing_id = ENEMY_SCAN_IDS[thing]
      collection = "EnemyScans"
      if ActiveRecord::Type::Boolean.new.cast(value)
        add_id_to_collection(collection, thing_id)
      else
        remove_id_from_collection(collection, thing_id)
      end
    end
  end

  {
    available_ship_items: 'SHIP_ITEM_IDS',
    available_story_logs: 'STORY_LOG_IDS',
    available_enemy_scans: 'ENEMY_SCAN_IDS'
  }.each do |method_name, constant_name|
    define_method(method_name) do
      available_items(constant_name)
    end
  end

  after_initialize :set_defaults

  belongs_to :user, optional: true

  before_validation :set_slug

  validates :title, presence: true, length: {maximum: 32}, allow_blank: false
  validates :description, presence: true, length: {maximum: 1000}, allow_blank: true

  def set_slug
    self.slug = title.parameterize
  end

  def current_planet_name
    MOON_IDS.invert[current_planet_id]
  end

  def increament_download_count!
    self.download_count += 1
    save
  end

  def save_file
    encrypt_aes(save_data_to_ordered_json, "lcslime14a5")
  end

  def save_data_to_ordered_json
    data = self.save_data.dup

    # I opted to have this problem when I camelized the keys and used the same name for the
    # inputs, params, etc. But its an easy fix, just some annoying naming convention.
    # Consider that if opting to change this behaviour, past saves must be modified.
    replacement_keys = {
      "ShipUnlockStored_LoudHorn" => "ShipUnlockStored_Loud horn",
      "ShipUnlockStored_GreenSuit" => "ShipUnlockStored_Green Suit",
      "ShipUnlockStored_CozyLights" => "ShipUnlockStored_Cozy Lights",
      "ShipUnlockStored_HazardSuit" => "ShipUnlockStored_Hazard Suit",
      "ShipUnlockStored_PijamaSuit" => "ShipUnlockStored_Pijama Suit",
      "ShipUnlockStored_FileCabinet" => "ShipUnlockStored_File Cabinet",
      "ShipUnlockStored_RecordPlayer" => "ShipUnlockStored_Record player",
      "ShipUnlockStored_RomanticTable" => "ShipUnlockStored_Romantic table",
      "ShipUnlockStored_InverseTeleporter" => "ShipUnlockStored_Inverse Teleporter",
      "ShipUnlockStored_SignalTransmitter" => "ShipUnlockStored_Signal transmitter",
    }

    replacement_keys.each do |current_key, new_key|
      data[new_key] = data.delete(current_key).sort.to_h if data[current_key].present?
    end

    raise self.class.default_save_data.deep_merge(data).inspect # s.to_json
  end

  def self.default_save_data
    @default_save_data ||= JSON.parse(File.read(Rails.root.join("config", "defaults", "save_default.json")))
  end

  private

  def set_defaults
    default_data = self.class.default_save_data
    self.save_data = default_data if save_data == {}
  end

  def available_items(constant_name)
    self.class.const_get(constant_name).keys.select { |item_name| send(item_name) }.map do |item_name|
      { name: item_name, id: self.class.const_get(constant_name)[item_name] }
    end
  end

  def set_ship_unlock_stored(item, value)
    unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
    save_data[unlock_stored_key] = {"__type" => "bool", "value" => value}
  end

  def remove_ship_unlock_stored(item)
    unlock_stored_key = "ShipUnlockStored_#{item.camelize}"
    save_data.delete(unlock_stored_key)
  end

  def add_id_to_collection(collection, thing_id)
    save_data[collection] ||= {"__type" => "System.Int32[],mscorlib", "value" => []}
    save_data[collection]["value"] << thing_id unless save_data[collection]["value"].include?(thing_id)
  end

  def remove_id_from_collection(collection, thing_id)
    save_data[collection]["value"].delete(thing_id) if save_data[collection]&.dig("value")&.include?(thing_id)
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
