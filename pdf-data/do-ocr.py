# Import required packages
import cv2
import pytesseract
import argparse
import os
from matplotlib import pyplot as plt
import numpy as np
from PIL import Image
from pathlib import Path

# https://www.youtube.com/watch?v=ADV-AjAXHdc
# https://github.com/wjbmattingly/ocr_python_textbook/blob/main/02_02_working%20with%20opencv.ipynb


def show_image(image):
    cv2.imshow('image',image)
    c = cv2.waitKey()
    if c >= 0 : return -1
    return 0

def invert_image(img):
  inverted_image = cv2.bitwise_not(img)
  #show_image(inverted_image)
  return inverted_image

def binarization(img):
  img2 = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
  thresh, img_bw = cv2.threshold(img2, 180, 210, cv2.THRESH_BINARY)
  #1881, 1892: thresh, img_bw = cv2.threshold(img2, 180, 210, cv2.THRESH_BINARY)
  #show_image(img_bw)
  return img_bw

def noise_removal(img):
  kernel = np.ones((1, 1), np.uint8)
  img = cv2.dilate(img, kernel, iterations=1)
  kernel = np.ones((1, 1), np.uint8)
  img = cv2.erode(img, kernel, iterations=1)
  img = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
  img = cv2.medianBlur(img, 3)
  return img

def thin_font(img):
  img = invert_image(img)
  kernel = np.ones((2, 2), np.uint8)
  img = cv2.erode(img, kernel, iterations=1)
  img = invert_image(img)
  return img

def thick_font(img):
  img = invert_image(img)
  kernel = np.ones((2, 2), np.uint8)
  img = cv2.dilate(img, kernel, iterations=1)
  img = invert_image(img)
  return img

def getSkewAngle(cvImage) -> float:
    # Prep image, copy, convert to gray scale, blur, and threshold
    newImage = cvImage.copy()
    gray = cv2.cvtColor(newImage, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (9, 9), 0)
    thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]

    # Apply dilate to merge text into meaningful lines/paragraphs.
    # Use larger kernel on X axis to merge characters into single line, cancelling out any spaces.
    # But use smaller kernel on Y axis to separate between different blocks of text
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (30, 5))
    dilate = cv2.dilate(thresh, kernel, iterations=2)

    # Find all contours
    contours, hierarchy = cv2.findContours(dilate, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key = cv2.contourArea, reverse = True)
    for c in contours:
        rect = cv2.boundingRect(c)
        x,y,w,h = rect
        cv2.rectangle(newImage,(x,y),(x+w,y+h),(0,255,0),2)

    # Find largest contour and surround in min area box
    largestContour = contours[0]
    print (len(contours))
    minAreaRect = cv2.minAreaRect(largestContour)
    cv2.imwrite("temp/boxes.jpg", newImage)
    # Determine the angle. Convert it to the value that was originally used to obtain skewed image
    angle = minAreaRect[-1]
    if angle < -45:
        angle = 90 + angle
    return -1.0 * angle

# Rotate the image around its center
def rotateImage(cvImage, angle: float):
    newImage = cvImage.copy()
    (h, w) = newImage.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    newImage = cv2.warpAffine(newImage, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
    return newImage

def deskew(cvImage):
  angle = getSkewAngle(cvImage)
  return rotateImage(cvImage, -1.0 * angle)

def remove_borders(img):
  img, contours, hierarchy = cv2.findContours(img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
  cntsSorted = sorted(contours, key=lambda x:cv2.contourArea(x))
  cnt = cntsSorted[-1]
  x, y, w, h = cv2.boundingRect(cnt)
  crop = img[y:y+h, x:x+w]
  return (crop)

def add_borders(img):
  color = [255, 255, 255]
  top, bottom, left, right = [150]*4
  img = cv2.copyMakeBorder(img, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)
  return img

def do_ocr(img):
  #img = Image.open(image_file)
  ocr_result = pytesseract.image_to_string(img)
  return ocr_result

def write(dir, filename, content):
  Path(dir).mkdir(parents=True, exist_ok=True)
  f = open(dir + filename, "w")
  f.write(content)
  f.close

# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument('-i', '--input_path', required = True, help = 'path to directory of png files')
ap.add_argument('-o', '--output_path', required = True, help = 'path to output directory of OCR')
args = vars(ap.parse_args())

# Load the files and convert them to images
images = args['input_path']
ocrs   = args['output_path']

for image_name in sorted(os.listdir(images)):
  if image_name.endswith('.tif'):
    img = cv2.imread(images + image_name)
    # process_image(images, image_name)
    #img = invert_image(img)
    img = binarization(img)
    #img = noise_removal(img)
    #img = thin_font(img)
    #img = thick_font(img)
    #show_image(img)
    img = remove_borders(img)
    #img = add_borders(img)
    result = do_ocr(img)
    #print(result)
    print("done: {}".format(image_name))
    write(ocrs, image_name + ".txt", result)
    
