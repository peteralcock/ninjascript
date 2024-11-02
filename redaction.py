import spacy
from PyPDF2 import PdfReader
import nltk
from nltk.corpus import stopwords
import fitz
import re
import argparse

nlp = spacy.load("en_core_web_sm")
stop = stopwords.words('english')

'''
Install the following packages for
- NLTK
nltk.download('punkt')
nltk.download('averaged_perceptron_tagger')
nltk.download('maxent_ne_chunker')
nltk.download('words')
nltk.download('stopwords')

- Spacy
python3 -m spacy download en_core_web_sm

'''

def extract_phone_numbers(string):
    r = re.compile(r'(\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\(\d{3}\)\s*\d{3}[-\.\s]??\d{4}|\d{3}[-\.\s]??\d{4})')
    phone_numbers = r.findall(string)
    return [re.sub(r'\D', '', number) for number in phone_numbers]


def extract_email_addresses(string):
    r = re.compile(r'[\w\.-]+@[\w\.-]+')
    return r.findall(string)


def ie_preprocess(document):
    document = ' '.join([i for i in document.split() if i not in stop])
    sentences = nltk.sent_tokenize(document)
    sentences = [nltk.word_tokenize(sent) for sent in sentences]
    sentences = [nltk.pos_tag(sent) for sent in sentences]
    return sentences


def extract_names(text):
    doc = nlp(text)
    names = []
    for ent in doc.ents:
        if ent.label_ == "PERSON":
            names.append(ent.text)
    return names


def verify_extracted_names(document):
    names = []
    sentences = ie_preprocess(document)
    for tagged_sentence in sentences:
        for chunk in nltk.ne_chunk(tagged_sentence):
            if type(chunk) == nltk.tree.Tree:
                if chunk.label() == 'PERSON':
                    names.append(' '.join([c[0] for c in chunk]))
    return names


def redact_pdf(input_file, regex_list, manual_words, output_file):
    doc = fitz.Document(input_file)
    # Loop for regex
    regex_words = []
    for item in regex_list:
        # loop for pages in current document
        for page in doc:
            # Get text from page separated by new line
            redact_data = page.get_text("text").split('\n')

            # loop for searching regex within each line and adding word to a list
            for line in redact_data:
                if re.search(item, line, re.IGNORECASE):
                    reg_search = str(re.search(item, line, re.IGNORECASE))
                    reg_str_individual = re.findall(r"'(.*?)'", reg_search)[0]
                    regex_words.append(reg_str_individual)
        # print(redact_data) - look at if it's not stored as text how can it read text in images.
    # combine added words, added regex to pre-determined lists
    words = manual_words + regex_words

    # redaction method - search for each word within each page by document
    for page in doc:
        for word in words:
            for instance in page.search_for(word, quads=True):
                areas = page.search_for(word)

                # fill area around the word and colour
                [page.add_redact_annot(area, fill=(0, 0, 0)) for area in areas]
                page.apply_redactions()

    # print file names
    print("\nRedacted: " + str(input_file))

    # doc.save("/Users/Dan/Downloads/Python Output"+filename, True) # stored output location
    doc.save(output_file, True)  # manually entered output location


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Redact PDF')
    parser.add_argument('-i', '--file_input', action='store', type=str, required=True, help='Input File', default='')
    parser.add_argument('-o', '--file_output', action='store', type=str, required=True, help='Output File', default='')
    args = parser.parse_args()
    file_input = args.file_input
    file_output = args.file_output
    document = PdfReader(file_input)
    text = document.pages[0].extract_text()
    print(text.title())
    phone_numbers = extract_phone_numbers(text.title())
    print(phone_numbers)
    emails = extract_email_addresses(text.title())
    print(emails)
    names_first_draft = extract_names(text.title())
    print(names_first_draft)
    names = []
    for n in names_first_draft:
        verified_name = ' '.join([x.lower() for x in verify_extracted_names(n)])
        names.append(verified_name)
    print(names)

    list_of_regex_words = phone_numbers + emails + names
    print(list_of_regex_words)
    redact_pdf(input_file=file_input, regex_list=list_of_regex_words, manual_words=[], output_file=file_output)
