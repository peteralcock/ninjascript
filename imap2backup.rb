# VERSION 2: Now including email attachment downloader!

require 'net/imap'
require 'mail'
require 'eml_to_pdf'
require 'fileutils'
require 'dotenv'
Dotenv.load

system("mkdir -p ATTACHMENTS")
system("mkdir -p EML_Files")
system("mkdir -p emails")
imap = Net::IMAP.new(ENV['IMAP_ADDRESS'], ssl: { 
verify_mode:
OpenSSL::SSL::VERIFY_NONE })
imap.authenticate(ENV['IMAP_LOGIN_TYPE'], ENV['IMAP_USERNAME'], ENV['IMAP_PASSWORD'])

imap.list("", "*").each do |mailbox|
 next if mailbox.attr.any? { |attr| [:Noselect,
:Noinferiors].include?(attr) }

 imap.select(mailbox.name)
 emails = []
 message_ids = imap.search(['ALL'])
 message_ids.each do |message_id|
   msg = imap.fetch(message_id,'BODY[]')[0].attr['BODY[]']
   mail = Mail.read_from_string msg
   timestamp = mail.date.to_s
   eml_filename = "EML_Files/#{timestamp}.eml"

   File.open(eml_filename, 'w') { |file| file.write(msg) }

   if mail.has_attachments?
     mail.attachments.each do |attachment|
       if attachment.content_type.start_with?('text/plain')
         mail.body = mail.body.decoded + attachment.body.decoded
       end

       FileUtils.mkdir_p("ATTACHMENTS/#{timestamp}")
       File.open("ATTACHMENTS/#{timestamp}/#{attachment.filename}",'w+b') { |file| file.write(attachment.body.decoded) }
     end
   end

   # Save the email with the appended text attachment body
   File.open(eml_filename, 'w') { |file| file.write(mail.to_s) }
    # Save email data to the emails array
  email_data = {
    to: mail.to,
    from: mail.from,
    subject: mail.subject,
    body: mail.multipart? ? mail.text_part.body.to_s : mail.body.to_s
  }
  emails << email_data
  
 end
end

# Export emails to CSV
CSV.open('emails/emails.csv', 'wb') do |csv|
  csv << ['To', 'From', 'Subject', 'Body']
  emails.each do |email|
    csv << [email[:to], email[:from], email[:subject], email[:body]]
  end
end

imap.logout
imap.disconnect
