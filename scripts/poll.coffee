# Description
# 	Vote on stuff!
#
# Dependencies:
# 	None
#
# Configuration:
# 	None
#
# Commands:
#	hubot poll create (timed) <name> - Start a poll with the name <name>
#
# Notes:
# 	None
#
# Author:
# 	davinche

module.exports = (robot) ->
	robot.polls =
		polls: []
		lookup: {}

	pollExist = (pollNum) ->
		if typeof pollNum is 'string' then pollNum = parseInt(pollNum, 10)
		if pollNum < robot.polls.polls.length then return true
		return false

	pollNotFound = (msg, num) ->
		msg.send "There is no Poll #{num}."

	pollFullName = (pollNum) ->
		if typeof pollNum is 'string' then pollNum = parseInt(pollNum, 10)
		return "Poll(#{pollNum}): \"#{robot.polls.polls[pollNum].name}\""


	# --------------------------------------------
	# Create a new Poll
	# --------------------------------------------

	robot.respond /poll create (timed\s)?(.+)$/i, (msg) ->
		pollName = msg.match[2]
		# Check to see if a poll with the same name already exists
		if robot.polls.lookup[pollName]
			msg.send "A poll called \"#{pollName}\" already exists!"
		else
			poll =
				name: pollName
				timed: msg.match[1]?
				choices: []
			# Add the new poll
			robot.polls.polls.push poll
			robot.polls.lookup[pollName] = poll
			msg.send "Poll \"#{pollName}\" has been created."


	# --------------------------------------------
	# Delete a Poll
	# --------------------------------------------

	robot.respond /poll (\d+) delete$/i, (msg) ->
		if not pollExist(msg.match[1]) then pollNotFound(msg, msg.match[1])
		else
			index = parseInt(msg.match[1], 10)
			poll = robot.polls.polls.splice(index, 1)[0]
			msg.send "Poll \"#{poll.name}\" has been deleted."
			delete robot.polls.lookup[poll.name]


	# --------------------------------------------
	# List all the Active Polls
	# --------------------------------------------

	robot.respond /poll list$/i, (msg) ->
		if robot.polls.polls.length
			response = "\nActive Polls\n"
			response += "---------------------------\n"
			for poll, index in robot.polls.polls
				response += "#{index}: #{poll.name}"
				response += "\n" unless index is (robot.polls.polls.length - 1)
			msg.send response
		else
			msg.send 'There are no polls.'


	# --------------------------------------------
	# Add Choices to a poll
	# --------------------------------------------

	robot.respond /poll (\d+) add choices \[(.+)\]$/i, (msg) ->
		if not pollExist(msg.match[1]) then pollNotFound(msg, msg.match[1])
		else
			pollNum = parseInt(msg.match[1], 10)
			poll = robot.polls.polls[pollNum]
			choices = msg.match[2].split(',')
			for choice in choices
				choice = choice.trim()
				if choice?
					poll.choices.push choice
			msg.send "Choices added to #{pollFullName(pollNum)}"

	robot.respond /poll (\d+) list choices$/i, (msg) ->
		if not pollExist(msg.match[1]) then pollNotFound(msg, msg.match[1])
		else
			pollNum = parseInt(msg.match[1], 10)
			if robot.polls.polls[pollNum].choices.length
				poll = robot.polls.polls[pollNum]
				response = "\nChoices for Poll #{pollNum}: \"#{poll.name}\"\n"
				response += "--------------------------------------------------\n"
				for choice,index in poll.choices
					response += "#{index}: #{choice}"
					response += "\n" unless index is (poll.choices.length - 1)
				msg.send response
			else
				msg.send "No choices has been added to Poll #{pollNum}."

