import os
import cgi
import logging
import md5
import base64
import utils
import urllib
import random
import os.path
import wsgiref.handlers

import hashlib
import hmac
import simplejson as json

from datetime import datetime
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.api import memcache
from mapreduce import operation as op


from google.appengine.ext.webapp import util


class AdminPage(webapp.RequestHandler):
     def get(self):
          template_values = {}
          path = os.path.join(os.path.dirname(__file__), 'jindex.html')
          self.response.out.write(template.render(path, template_values))

application = webapp.WSGIApplication([('/.*', AdminPage),
                                      ('/adminPage', AdminPage),],
                                                  debug=True)

def main():
  util.run_wsgi_app(application)
if __name__ == "__main__":
  main() 