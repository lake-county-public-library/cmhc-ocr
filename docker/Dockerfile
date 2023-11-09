FROM docker.io/unikrn/python-opencv:latest

RUN apt-get update && \
    apt-get install -y tesseract-ocr-all && \
    apt-get install -y libcanberra-gtk-module && \
    apt-get install -y rename && \
    apt-get install -y poppler-utils && \
    pip install pytesseract

RUN useradd --create-home MARMOT+awoods
RUN groupadd MARMOT+domain
RUN usermod -G MARMOT+domain MARMOT+awoods

# Update permissions for the etdadm user and group
COPY change_id.sh /root/change_id.sh
RUN chmod 755 /root/change_id.sh && \
  /root/change_id.sh -u 2009348 -g 2000513

USER MARMOT+awoods

#CMD ["bash"]
