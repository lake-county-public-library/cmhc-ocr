import csv
import os
import argparse
      

fieldnames = ['pid', 'label',	'key', 'location', 'keywords', 'description', 'named_persons', 'rights', 'creation_date', 'ingest_date', 'format', 'source', 'order', 'layout', 'text', 'thumbnail', 'full', 'manifest', 'collection']


def load_csv(f):
  sheet = {}
  with open(f, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
      sheet[row['pid']] = row

  return sheet

def get_highest_order(sheet):
  highest = 0
  for row in sheet.values():
    if row['order']:
      current_order = int(row['order'])
      if current_order > highest:
        highest = current_order

  return highest


# Return dict of row
def get_row(pid, highest_order, sheet):
  row = {}
  if pid not in sheet:
    highest_order = highest_order+1
    row['order'] = highest_order
    row['pid'] = pid
    return row, highest_order
  else:
    return sheet[pid], highest_order


# Add updated row to sheet
def put_data_into_row(pid, highest_order, sheet, field, data):
  row, highest_order = get_row(pid, highest_order, sheet)
  row[field] = data
  sheet[pid] = row

  return highest_order
  

def populate_csv(sheet, dir, csv_filename, fields, highest_order):
  for filename in sorted(os.listdir(dir)):
    pid = os.path.basename(filename).split('.')[0]

    f = os.path.join(dir, filename)

    # Read txt from file into a single line
    if os.path.isfile(f):
      with open(f, mode="r", encoding="utf-8") as txt:
        data = txt.read()
        line = ' '.join(data.splitlines())

        highest_order = put_data_into_row(pid, highest_order, sheet, 'text', line)

        for field in fields:
          f = field.split(':')[0]
          v = field.split(':')[1]
          put_data_into_row(pid, highest_order, sheet, f, v)

    # Write CSV
    with open(csv_filename, mode='w') as csv_file:
      writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
      writer.writeheader()
      
      for pid in sheet:
        writer.writerow(sheet[pid])


# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument('-c', '--csv', required = True, help = 'path to csv file')
ap.add_argument('-t', '--txt', required = True, help = 'path to full text dir')
ap.add_argument('-f', '--field_and_value', required = False, help = 'field:value in sheet to update', action='append')
args = vars(ap.parse_args())

# Load the csv file
csv_filename = args['csv']
sheet = load_csv(csv_filename)
highest_order = get_highest_order(sheet)

# Load txt from full-text files
txt_dir = args['txt']

# Load additional field/values that will be populated for all PIDs
fields = args['field_and_value']

populate_csv(sheet, txt_dir, csv_filename, fields, highest_order)
