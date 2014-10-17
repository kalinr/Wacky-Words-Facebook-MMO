#began project on 8/27/2011


FACEBOOK_APP_ID = "115706881865455"#dev
FACEBOOK_APP_SECRET = "e7eb3e5cd832eb068e6acf9485a9e4d3"#dev
CANVAS_PAGE = "http://apps.facebook.com/salesworlddev/"#dev


FACEBOOK_APP_ID = "213142532083793"#prod
FACEBOOK_APP_SECRET = "4538560c12726b4b8d30d732f97d9206"#prod
CANVAS_PAGE = "http://apps.facebook.com/wackywords/"#prod




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
import math

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

class NounCard(db.Model):
     wordString = db.StringProperty()
     wordDescription = db.StringProperty()
     creationDate = db.DateTimeProperty(auto_now_add = True)
     
class VerbCard(db.Model):
     wordString = db.StringProperty()
     wordDescription = db.StringProperty()
     creationDate = db.DateTimeProperty(auto_now_add = True)
     
class AdjectiveCard(db.Model):
     wordString = db.StringProperty()
     wordDescription = db.StringProperty()
     creationDate = db.DateTimeProperty(auto_now_add = True)
     
class Product(db.Model):
     productString = db.StringProperty()
     salesPitch = db.TextProperty()
     user_id = db.StringProperty()
     upVoteCount = db.IntegerProperty(default=0)
     downVoteCount = db.IntegerProperty(default=0)
     votesSincePayout = db.IntegerProperty(default=0)
     creationDate = db.DateTimeProperty(auto_now_add = True)

class User(db.Model):
    id = db.StringProperty()
    created = db.DateTimeProperty(auto_now_add=True)
    updated = db.DateTimeProperty(auto_now=True)
    upVoteCount = db.IntegerProperty(default=4)
    upVoteDailyBonus = db.IntegerProperty(default=4)
    upVoteMax = db.IntegerProperty(default=7)
    downVoteCount = db.IntegerProperty(default=4)
    downVoteDailyBonus = db.IntegerProperty(default=4)
    downVoteMax = db.IntegerProperty(default=7)
    wordDrawCount = db.IntegerProperty(default=5)
    wordDrawDailyBonus = db.IntegerProperty(default=5)
    wordDrawMax = db.IntegerProperty(default=12)
    wordHandMax = db.IntegerProperty(default=10)
    createCount = db.IntegerProperty(default=1)
    createDailyBonus = db.IntegerProperty(default=1)
    createMax = db.IntegerProperty(default=3)
    investmentTokens = db.IntegerProperty(default=3)
    gold = db.IntegerProperty(default=100)
    oauth_token = db.StringProperty()
    experiencePoints = db.IntegerProperty(default=0)
    skillPoints = db.IntegerProperty(default=0)
    upVoteDailyBonus_lvl = db.IntegerProperty(default=0)
    upVoteMax_lvl = db.IntegerProperty(default=0)
    downVoteDailyBonus_lvl = db.IntegerProperty(default=0)
    downVoteMax_lvl = db.IntegerProperty(default=0)
    wordDrawDailyBonus_lvl = db.IntegerProperty(default=0)
    wordDrawMax_lvl = db.IntegerProperty(default=0)
    wordHandMax_lvl = db.IntegerProperty(default=0)
    createDailyBonus_lvl = db.IntegerProperty(default=0)
    createMax_lvl = db.IntegerProperty(default=0)
      
class Investment(db.Model):
    product_id = db.StringProperty()
    user_id = db.StringProperty()
    created = db.DateTimeProperty(auto_now_add=True)

class UserPurchase(db.Model):
    user_id = db.StringProperty()
    date = db.DateTimeProperty(auto_now_add = True)
    type = db.StringProperty()
    level = db.IntegerProperty(default=0)
     
def base64_url_decode(inp):
     padding_factor = (4 - len(inp) % 4) % 4
     inp += "="*padding_factor 
     return base64.b64decode(unicode(inp).translate(dict(zip(map(ord, u'-_'), u'+/'))))

def parse_signed_request(signed_request, secret):
     l = signed_request.split('.', 2)
     encoded_sig = l[0]
     payload = l[1]
     sig = base64_url_decode(encoded_sig)
     data = json.loads(base64_url_decode(payload))
     if data.get('algorithm').upper() != 'HMAC-SHA256':
          #log.error('Unknown algorithm')
          return None
     else:
          expected_sig = hmac.new(secret, msg=payload, digestmod=hashlib.sha256).digest()
     if sig != expected_sig:
          return None
     else:
          #log.debug('valid signed request received..')
          return data
     
class MainPage(webapp.RequestHandler):
     def post(self):
          vars = self.request.get('signed_request')
          vars = parse_signed_request(vars, FACEBOOK_APP_SECRET)
          userID = vars.get('user_id')
          
          if userID:
                oauthToken = vars.get('oauth_token')
                user = User.get_by_key_name(userID)
                if not user:
                     user = User(key_name=str(userID), id=str(userID))
                     user.oauth_token=oauthToken
                     user.put()
                elif user.oauth_token != oauthToken:
                     user.oauth_token = oauthToken
                     user.put()
                userData = utils.GqlEncoder().encode(user)
                userData = urllib.quote(userData)
                template_values = {'user_id':userID, 'oauth_token':oauthToken, 'user_data':userData}
                self.response.out.write(template.render('jindex2.html', template_values) )
          else:
                #add a cookie if we've already been here
                auth_url = "https://www.facebook.com/dialog/oauth?client_id=" + FACEBOOK_APP_ID + "&redirect_uri=" + CANVAS_PAGE;
                self.response.out.write("<script> top.location.href='" + auth_url + "'</script>")
                #echo("<script> top.location.href='" . $auth_url . "'</script>");
                #self.response.headers['Window-target'] = "_top"
                #self.redirect(auth_url)
	
class DrawCard(webapp.RequestHandler):
    def post(self):
     	wordType = self.request.get('type')
    	cacheID = ""
        if wordType == 'n':
    	     cacheID = "nCache"
        elif wordType == 'a':
    	     cacheID = "aCache"
        elif wordType == 'v':
    	     cacheID = "vCache"
        customObject = memcache.get(cacheID)  
        if customObject is None:
    	     customObject = []
    	     if wordType == 'n':
    	          fieldQuery = NounCard.all()
    	     elif wordType == 'a':
    	          fieldQuery = AdjectiveCard.all()
    	     elif wordType == 'v':
    	     	fieldQuery = VerbCard.all()
    	     #results.filter("wordString =", "efefef")
    	     results = fieldQuery.fetch(limit=999)
    	     for customField in results:
    	     	customObject.append({ 'wordString':str(customField.wordString), 'wordDescription':str(customField.wordDescription) })
    	     memcache.add(cacheID, customObject)
        randIndex = random.randint(0, len(customObject) - 1)
        outputDictionary = {}
        outputDictionary['word'] = customObject[randIndex]['wordString']
        outputDictionary['wordDescription'] = customObject[randIndex]['wordDescription']
        outputDictionary['response'] = 'success'
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))
        #self.response.out.write('word=' + customObject[randIndex]['wordString'] + '&wordDescription=' + customObject[randIndex]['wordDescription'])

class SubmitProduct(webapp.RequestHandler):
    def post(self):
        outputDictionary = {}
        user = User.get_by_key_name(self.request.get('user_id'))
        if not user:
            #self.response.out.write('result=no user with this ID')
            outputDictionary['response'] = "no user with this ID"
        elif user.oauth_token != self.request.get('oauth_token'):
            #self.response.out.write('result=oauth_token did not match')
            outputDictionary['response'] = "oauth_token did not match"
        else:
            product = Product();
            product.productString = self.request.get('productString').replace(',', ' ')
            product.salesPitch = self.request.get('salesPitch')
            product.user_id = self.request.get('user_id')
            product.put()
            memcache.delete("IDCache")
            outputDictionary['response'] = "success"
            #self.response.out.write('result=success')
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))
	
class GetProduct(webapp.RequestHandler):
     def post(self):
     	rand = random.random()
     	IDCache = memcache.get("IDCache")
     	if IDCache is None:
     	     IDQuery = Product.all(keys_only=True)
     	     IDCache = IDQuery.fetch(limit=999999)
     	     memcache.add("IDCache", IDCache)
     	random_key = random.sample(IDCache, 1)
     	items = db.get(random_key)
        if not items[0].user_id:
            items[0].user_id = "100000248328000" #Kalin's user id
            items[0].put()
        outputDictionary = {}
        outputDictionary['user_id'] = items[0].user_id
        outputDictionary['productString'] = items[0].productString
        outputDictionary['salesPitch'] = items[0].salesPitch
        outputDictionary['upVoteCount'] = items[0].upVoteCount
        outputDictionary['downVoteCount'] = items[0].downVoteCount
        outputDictionary['creationDate'] = str(items[0].creationDate)
        outputDictionary['key'] = items[0].key().id()
        outputDictionary['response'] = "success"
          #hello = urllib.urlencode("poopy")
          
        self.response.out.write(utils.GqlEncoder().encode(outputDictionary))
          #self.response.out.write("response=success&user_id=" + items[0].user_id + "&productString=" + items[0].productString 
          #                + "&salesPitch=" + items[0].salesPitch + "&creationDate=" + str(items[0].creationDate))          

class ProductVote(webapp.RequestHandler):
    def post(self):
        outputDictionary = {}
        user = User.get_by_key_name(self.request.get('user_id'))
        if not user:
            outputDictionary['response'] = "no user with this ID"
        elif user.oauth_token != self.request.get('oauth_token'):
            outputDictionary['response'] = "oauth_token did not match"
        else:
           voteType = self.request.get('voteType')
           if (voteType == "up" and user.upVoteCount == 0) or (voteType == "down" and user.downVoteCount == 0):
               outputDictionary['response'] = "you are out of votes"
           else:
               product = Product.get_by_id(long(self.request.get('key')))
               if(voteType == "up"):
                   user.upVoteCount -= 1
                   user.experiencePoints += 200
                   user.skillPoints += 200
                   outputDictionary['experienceUp'] = 200;
                   product.upVoteCount += 1
                   product.votesSincePayout += 1
               else:
                   user.downVoteCount -= 1
                   user.experiencePoints += 100
                   user.skillPoints += 100
                   outputDictionary['experienceUp'] = 100;
                   product.downVoteCount += 1
               outputDictionary['userXP'] = user.experiencePoints
               outputDictionary['userSP'] = user.skillPoints
               outputDictionary['userUpVoteCount'] = user.upVoteCount
               outputDictionary['userDownVoteCount'] = user.downVoteCount
               outputDictionary['productUpVoteCount'] = product.upVoteCount
               outputDictionary['productDownVoteCount'] = product.downVoteCount
               outputDictionary['key'] = product.key().id()
               outputDictionary['response'] = "success"
               product.put()
               user.put()
        self.response.headers['Content-Type'] = "application/json"
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))

class Invest(webapp.RequestHandler):
    def post(self):
        outputDictionary = {}
        user = User.get_by_key_name(self.request.get('user_id'))
        if not user:
            outputDictionary['response'] = "no user with this ID."
        elif user.oauth_token != self.request.get('oauth_token'):
            outputDictionary['response'] = "oauth_token did not match."
        else:
            product = Product.get_by_id(long(self.request.get('key')))
            if user.investmentTokens == 0:
                 outputDictionary['response'] = "you are out of investment tokens."
            else:
                 user.investmentTokens -= 1
                 user.experiencePoints += 250
                 user.skillPoints += 250
                 outputDictionary['experienceUp'] = 250
                 outputDictionary['userXP'] = user.experiencePoints
                 outputDictionary['userSP'] = user.skillPoints
                 investment = Investment()
                 investment.user_id = self.request.get('user_id')
                 investment.product_id = self.request.get('key')
                 outputDictionary['investmentTokens'] = user.investmentTokens
                 outputDictionary['response'] = "success"
                 investment.put()
                 user.put()
        self.response.headers['Content-Type'] = "application/json"
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))

#this is potentially a security threat because the values are dynamic, so theoretically you could pass in any User field, not just our skill fields
class BuySkill(webapp.RequestHandler):
    def post(self):
        outputDictionary = {}
        user = User.get_by_key_name(self.request.get('user_id'))
        if not user:
            outputDictionary['response'] = "no user with this ID."
        elif user.oauth_token != self.request.get('oauth_token'):
            outputDictionary['response'] = "oauth_token did not match."
        else:
            skillLevels = memcache.get("skillLevels")
            if skillLevels is None:
                skillLevels = [300, 849, 1559, 2400, 3354, 4409, 5556, 6788, 8100, 9487, 10945, 12471, 14062, 15715, 17428, 19200, 21028, 22910, 24846, 26833, 28870, 30957, 33091, 35273, 37500]
                memcache.add("skillLevels", skillLevels)
            field = self.request.get('field')
            skillType_lvl = field + "_lvl"
            #array is zero indexed so user's current level is equal to index of next level sp value
            skillLevel = getattr(user, skillType_lvl)
            nextSkillPoints = skillLevels[skillLevel] - skillLevels[skillLevel - 1]
            nextLevel = skillLevel + 1
            if user.skillPoints > nextSkillPoints:
                user.skillPoints -= nextSkillPoints
                setattr(user, skillType_lvl, nextLevel)
                newFieldValue = getattr(user, field) + 1
                setattr(user, field, newFieldValue)
                outputDictionary['userSP'] = user.skillPoints
                outputDictionary['lvl'] = nextLevel
                outputDictionary['newFieldValue'] = newFieldValue
                outputDictionary['response'] = "success"
                user.put()
            else:
                outputDictionary['response'] = "Server says you do not have enough skill points. Current skill points: " + user.skillPoints + ". Next level: " + nextSkillPoints + "."
        self.response.headers['Content-Type'] = "application/json"
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))
            
           

class AdminPage(webapp.RequestHandler):
    def get(self):
        template_values = {}
        path = os.path.join(os.path.dirname(__file__), 'jindex.html')
        self.response.out.write(template.render(path, template_values))

class SubmitWordCard(webapp.RequestHandler):
    def post(self):
        outputDictionary = {}
        wordType = self.request.get('wordType')
        if wordType == 'n':
            wordQuery = db.GqlQuery("SELECT * FROM NounCard WHERE wordString = '" + self.request.get('wordString') + "'")
            wordCard = NounCard()
            memcache.delete("nCache")
        elif wordType == 'a':
            wordQuery = db.GqlQuery("SELECT * FROM AdjectiveCard WHERE wordString = '" + self.request.get('wordString') + "'")
            wordCard = AdjectiveCard()
            memcache.delete("aCache")
        elif wordType == 'v':
            wordQuery = db.GqlQuery("SELECT * FROM VerbCard WHERE wordString = '" + self.request.get('wordString') + "'")
            wordCard = VerbCard()
            memcache.delete("vCache")
        if wordQuery.count() > 0:
            outputDictionary['response'] = "This word already exists"
        else:
            wordCard.wordString = self.request.get('wordString')
            wordCard.wordDescription = self.request.get('wordDescription')
            wordCard.put()
            outputDictionary['response'] = "success"
        self.response.headers['Content-Type'] = "application/json"
        self.response.out.write(json.JSONEncoder().encode(outputDictionary))

def dailyInvestmentPayout(entity):
    if entity.votesSincePayout > 0:
        investmentQuery = db.GqlQuery("SELECT * FROM Investment WHERE product_id = '" + str(entity.key().id()) + "'")
        results = investmentQuery.fetch(limit=100)
        if len(results) > 0:
            bonus = math.ceil(100/len(results)*entity.votesSincePayout)
            for investment in results:
                user = User.get_by_key_name(investment.user_id)
                user.gold += long(bonus)
                user.experiencePoints += long(bonus)
                user.skillPoints += long(bonus)
                user.put()
        entity.votesSincePayout  = 0
    yield op.db.Put(entity)
         
def dailyUserUpdate(entity):
    entity.upVoteCount += entity.upVoteDailyBonus
    if entity.upVoteCount > entity.upVoteMax:
        entity.upVoteCount = entity.upVoteMax
        
    entity.downVoteCount += entity.downVoteDailyBonus
    if entity.downVoteCount > entity.downVoteMax:
        entity.downVoteCount = entity.downVoteMax
    
    entity.wordDrawCount += entity.wordDrawDailyBonus
    if entity.wordDrawCount > entity.wordDrawMax:
       entity.wordDrawCount = entity.wordDrawMax
    
    entity.createCount += entity.createDailyBonus
    if entity.createCount > entity.createMax:
        entity.createCount = entity.createMax

    yield op.db.Put(entity)
    
def weeklyUserUpdate(entity):
    entity.investmentTokens += 1
    if entity.investmentTokens > 6:
        entity.investmentTokens = 6
    yield op.db.Put(entity)
  
        
application = webapp.WSGIApplication([('/', MainPage),
					('/drawCard', DrawCard),
					('/submitProduct', SubmitProduct),
					('/getProduct', GetProduct),
                    ('/productVote', ProductVote),
                    ('/invest', Invest),
                    ('/buySkill', BuySkill),
                    ('/adminPage', AdminPage),
                                                     ('/submitWordCard', SubmitWordCard)
                                                          ],
                                                  debug=True)

def main():
     run_wsgi_app(application)

if __name__ == "__main__":
     main()