# "Top level" templates:
#   "blackboard" -- main blackboard page
#   "puzzle"     -- puzzle information page
#   "round"      -- round information (much like the puzzle page)
#   "chat"       -- chat room

Template.page.currentPage = -> (Session.get "currentPage") or "blackboard"

Handlebars.registerHelper "equal", (a, b) -> a is b

CLIENT_UUID = Meteor.uuid() # this identifies this particular client instance

# subscribe to the all-names feed all the time
Meteor.subscribe 'all-names'
# always subscribe to your own nick
Meteor.autosubscribe ->
  return unless Session.get('nick')
  Meteor.subscribe 'my-nick', Session.get('nick')

# Router
BlackboardRouter = Backbone.Router.extend
  routes:
    "": "BlackboardPage"
    "rounds/:round": "RoundPage"
    "puzzles/:puzzle": "PuzzlePage"
    "chat/:type/:id": "ChatPage"

  BlackboardPage: ->
    this.Page("blackboard", "general", "0")

  RoundPage: (round) ->
    this.Page("round", "rounds", id)

  PuzzlePage: (puzzle) ->
    this.Page("puzzle", "puzzles", puzzle)

  ChatPage: (type,id) ->
    id = "0" if type is "general"
    this.Page("chat", type, id)
    Session.set "room_name", (type+'/'+id)

  Page: (page, type, id) ->
    Session.set "currentPage", page
    Session.set "type", type
    Session.set "id", id
    # cancel modal if it was active
    $('#nickPickModal').modal 'hide'

  urlFor: (type,id) ->
    "/#{type}/#{id}"
  chatUrlFor: (type, id) ->
    "/chat" + this.urlFor(type,id)

  goToRound: (round) ->
    this.navigate(this.urlFor("rounds",round._id), {trigger:true})

  goToPuzzle: (puzzle) ->
    this.navigate(this.urlFor("puzzles",puzzle._id), {trigger:true})

  goToChat: (type, id) ->
    this.navigate(this.chatUrlFor(type, id), {trigger:true})

Router = new BlackboardRouter()
Backbone.history.start {pushState: true}
