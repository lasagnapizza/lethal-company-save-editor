require "openssl"
require "json"

def create_cipher(mode, password, salt, iter = 100, key_len = 16, digest = "SHA1")
  cipher = OpenSSL::Cipher.new("AES-128-CBC")
  cipher.send(mode)
  cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, key_len, digest)
  cipher.iv = salt if mode == :decrypt # For decryption, IV is the salt
  cipher
end

def decrypt_aes(encrypted_data, password)
  iv = encrypted_data[0..15] # Extract IV from the start of the data
  cipher = create_cipher(:decrypt, password, iv)
  encrypted_data = encrypted_data[16..] # The rest is the encrypted data
  cipher.update(encrypted_data) + cipher.final
rescue OpenSSL::Cipher::CipherError => e
  puts "Error decrypting data: #{e.message}"
  nil
end

def encrypt_aes(data, password)
  cipher = OpenSSL::Cipher.new("AES-128-CBC")
  cipher.encrypt
  iv = cipher.random_iv # Generate a random IV for encryption
  cipher.key = OpenSSL::PKCS5.pbkdf2_hmac(password, iv, 100, 16, "SHA1")
  cipher.iv = iv
  encrypted_data = cipher.update(data) + cipher.final
  iv + encrypted_data # Prepend IV to encrypted data
rescue OpenSSL::Cipher::CipherError => e
  puts "Error encrypting data: #{e.message}"
  nil
end

def read_save_file(file_path)
  File.binread(file_path)
rescue Errno::ENOENT => e
  puts "Error reading file: #{e.message}"
  nil
end

def write_to_file(file_path, data)
  File.binwrite(file_path, data)
  puts "Data written to #{file_path}"
rescue IOError => e
  puts "Error writing to file: #{e.message}"
end

# Replace with your actual file paths and password
input_file_path = "/mnt/c/Users/kindu/AppData/LocalLow/ZeekerssRBLX/Lethal Company/LCSaveFile1"
output_file_path = "/mnt/c/Users/kindu/AppData/LocalLow/ZeekerssRBLX/Lethal Company/LCSaveFile1.decrypted"
encrypted_output_file_path = "/mnt/c/Users/kindu/AppData/LocalLow/ZeekerssRBLX/Lethal Company/LCSaveFile1"
password = "lcslime14a5"

# Decrypting and processing the file
encrypted_data = read_save_file(input_file_path)
if encrypted_data
  decrypted_data = decrypt_aes(encrypted_data, password)
  if decrypted_data
    puts "Decrypted Data: #{decrypted_data}"
    write_to_file(output_file_path, decrypted_data)

    # Prompt the user to modify the decrypted file and then press Enter
    puts "Modify the decrypted file at #{output_file_path} then press Enter to continue."
    gets # Waits for the user to press Enter

    # Read the modified file
    modified_data = read_save_file(output_file_path)
    if modified_data
      # Re-encrypt and save the modified data
      re_encrypted_data = encrypt_aes(modified_data, password)
      write_to_file(encrypted_output_file_path, re_encrypted_data) if re_encrypted_data
    end
  end
end
