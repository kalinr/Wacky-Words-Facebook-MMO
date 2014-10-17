"""
 Created by Andrin von Rechenberg, 2011.
 
 This library is free software: you can redistribute it
 and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation, either version 3 of
 the License, or (at your option) any later version.

 Example usage:
   http://devblog.miumeet.com/2011/02/schedule-mapreduce-daily-on-appengine.html    
 
Cheers,
 -Andrin

"""

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util

from mapreduce import control as mr_control

class ScheduleMapReduce(webapp.RequestHandler):
  def get(self):
    mr_control.start_map(
     self.request.get("name"),
     self.request.get("reader_spec", "your_mapreduce.map"),
     self.request.get("reader_parameters",
                      "mapreduce.input_readers.DatastoreInputReader"),
     { "entity_kind": self.request.get("entity_kind", "models.YourModel"),
       "processing_rate": int(self.request.get("processing_rate", 100)) },
     mapreduce_parameters={"done_callback": self.request.get("done_callback",
                                                             None) } )
    self.response.out.write("MapReduce scheduled");

application = webapp.WSGIApplication([
  ('/.*', ScheduleMapReduce),
], debug=True)


def main():
  util.run_wsgi_app(application)
if __name__ == "__main__":
  main() 