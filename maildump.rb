require 'net/imap'
require 'mail'
require 'csv'
require 'fileutils'

# IMAP Configuration
imap_server = ENV['IMAP_ADDRESS'] || 'imap.gmail.com'
imap_port = ENV['IMAP_PORT'] || 993
username = ENV['IMAP_USERNAME']
password = ENV['IMAP_PASSWORD']
login_type = ENV['IMAP_LOGIN_TYPE'] || "PLAIN"


# Create folders to store EML and MBOX files
FileUtils.mkdir_p('emails/eml')
FileUtils.mkdir_p('emails/mbox')

# Connect to IMAP mailbox
imap = Net::IMAP.new(imap_server, imap_port, true)
if imap.login(username, password)
imap.select('INBOX')
end
# Fetch the last 10000 emails
mail_ids = imap.search(['ALL']).last(10000)

# Initialize an array of hashes to store email data
emails = []
$all_emails = []
file = File.open("allemails.txt", "wb")
mail_ids.each do |mail_id|
  begin
  msg = imap.fetch(mail_id, 'RFC822')[0].attr['RFC822']
  mail = Mail.new(msg)
  msgbody = mail.multipart? ? mail.text_part.body.to_s : mail.body.to_s
  subject = mail.subject
  from = mail.from
  hash = {}
  hash['from'] = from
  hash['subject'] = subject
  hash['message'] = msgbody
  $all_emails << hash
  file << [hash,"\n"].join
  puts msgbody

  # Save email data to the emails array
  email_data = {
    to: mail.to,
    from: mail.from,
    subject: mail.subject,
    body: mail.multipart? ? mail.text_part.body.to_s : mail.body.to_s
  }
  emails << email_data

  # Save email as EML file
  File.open("emails/eml/#{mail_id}.eml", 'w') { |file| file.write(msg) }
  rescue => details
    puts details
  end
end

file.close

# Export emails to CSV
CSV.open('emails/emails.csv', 'wb') do |csv|
  csv << ['To', 'From', 'Subject', 'Body']
  emails.each do |email|
  begin
    csv << [email[:to], email[:from], email[:subject], email[:body]]
  rescue => details 
    puts details
  end 

  end
end

# Method to export emails to MBOX format
def export_to_mbox(emails)
  mbox_file = File.open('emails/emails.mbox', 'w')

  emails.each do |email|
    mbox_file.puts "From #{email[:from].first} #{Time.now.strftime('%a %b %d %H:%M:%S %Y')}"
    mbox_file.puts "Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S %z')}"
    mbox_file.puts "From: #{email[:from].first}"
    mbox_file.puts "To: #{email[:to].first}"
    mbox_file.puts "Subject: #{email[:subject]}"
    mbox_file.puts
    mbox_file.puts email[:body]
    mbox_file.puts
  end

  mbox_file.close
end

# Export emails to MBOX format
export_to_mbox(emails)

# Logout and disconnect from the IMAP server
imap.logout
imap.disconnect
